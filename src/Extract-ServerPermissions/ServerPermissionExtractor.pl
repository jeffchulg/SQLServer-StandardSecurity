#!/usr/bin/perl -w

#================================================================================
#   DESCRIPTION
#       This scripts builds a script which extracts server security and generates 
#		a set of MERGE statements to run against a security standard inventory 
#		database.
#		If specified, this script will run those statements directly to the 
#		inventory database. 
#
#   PREREQUIS /
#
#   AUTEURS
#       Bernard.bozet     < bernard.bozet@chu.ulg.ac.be >
#       Jefferson Elias   < jelias@chu.ulg.ac.be >
#       Vincent Bouquette < vincent.bouquette@chu.ulg.ac.be >
#
#================================================================================
#
#   Revision history
#
#   Date        Nom                 Description
#   ==========  ================    =============================================
#	2015		Jefferson Elias		Version 0.1.0
#================================================================================


#===============================================================================
# Include Modules
#===============================================================================

use strict;
use warnings;
use DBI;
use Switch;
use Config;
use Fcntl;
use File::Spec::Functions qw( canonpath );
use Getopt::Long qw(:config no_ignore_case bundling);
use File::Slurp;
use Data::Dumper;

#===============================================================================
# User parameters
#===============================================================================

my $DEBUG = 0;
my %params = (
	sqltemplates => [
		{
			file 	=> canonpath ("./ETL-LoginsAndContacts.tpl.sql"),
			tables 	=> [
				"Logins",
				"Contacts"
			],
			ignore 	=> 'N'
		}
		,
		{
			file 	=> canonpath ("./ETL-DatabaseSchemas.tpl.sql"),
			tables 	=> [
				"DatabaseSchema"
			],
			ignore 	=> 'N'
		}
	],
	dbParams => {
		inventoryDb => { # it only uses windows authentication at the moment
			Host 	=> "SI-S-SERV236", 
			DbName 	=> "TEST_SecurityInventory",
			RDBMS 	=> "MSSQL",
			dbh		=> ''
		},
		targetDb => {
			Host 	=> "",
			DbName 	=> "",
			RDBMS 	=> "MSSQL",
			dbh 	=> ""
		}
	},
	fileout_merge_statement => "./set_ServerPermissions.sql"
);

# --------------------------------------------------------------------------------------------#

#===============================================================================
# Global Variables Declaration
#===============================================================================


use vars qw($DEBUG);

my $programName    = $0;            # nom du fichier appelé pour exécuter ce programme
my $programVersion = "v0.1.0";      # numero de version
my $VersionDate    = "01/01/2015";  # date de la version

my $programHead = "$programName $programVersion\n---------------------------------------------------------\n\n";

#===============================================================================
# Prototypes Section
#===============================================================================

sub perform_action;                         # where the business logic starts
sub InitGlobals;                            # Initializes global variables
sub ProcessArgs;                            # manages command line parameters


# ---------------------
# functions
# ---------------------


# ----------------------
#       Utils
# ----------------------
sub executeMultipleStatements ;

# Logging
sub preformattedPrint ;                     # displays a string "<indent_param><head_param>: <message_param>"
sub Info ;
sub MyErr ;
sub MyWarn;
sub MyDie ;
sub Debug;


#===============================================================================
# Main function 
#===============================================================================

{
#    InitGlobals();
#    ProcessArgs();

    print $programHead;

    Debug "Debut perform_action";
    perform_action();
    Debug "Fin perform_action";

    exit(0);
}

#===============================================================================
# Prototype functions implementation
#===============================================================================

sub perform_action {

	InitGlobals();
    ProcessArgs();
	
	if(ValidateArgs() != 0) {
		MyErr "Validation Error. Avorting";
	}
	
	foreach my $dbDesc (keys %{$params{dbParams}}) {
		Debug "Connection to database " . $dbDesc . ".";
	
		my $connectionString =  "DBI:ADO:Provider=SQLNCLI10.1;Integrated Security=SSPI;Persist Security Info=False;User ID=\"\";Initial Catalog=" . 
								$params{dbParams}{$dbDesc}{DbName} . ";Data Source=" . $params{dbParams}{$dbDesc}{Host} . ";Initial File Name=\"\";Server SPN=\"\";";
	
		my $dbh;
	
		eval {
	
			$dbh = $params{dbParams}{$dbDesc}{dbh} = DBI->connect($connectionString) ;
			$dbh->{RaiseError} = 1;
		};
	
		if($@ || !$dbh) {
			MyErr "An error occurred while trying to connect to database " . $dbDesc ;
			if ($DBI::errstr) {
				MyErr $DBI::errstr ;
			}
		
			if ($@) {
				MyErr $@;
			}
			$@ = "A mandatory database connection is missing => Avorting" ;
			last;
		}
		else {
			Info "Connection to database " . $dbDesc . " established.";
		}
	}
	
	if($@) {
		Info "Taking care of MERGE statement generation";
		Debug "Diconnnecting from databases" ;
		
		foreach my $dbParam (keys %{$params{dbParams}}) {
			my %database = %{$params{dbParams}{$dbParam}};
			
			if($database{dbh}) {
				eval {
					$database{dbh}->disconnect();
				};
				if( $@ ) {
					MyErr "Unable to disconnect from server " . $dbParam;
				}
				else {
					Info "Disconnected from server " . $dbParam ;
				}
			}
		}
			
		return 1;
	}
	my @sqltemplates 	= @{$params{sqltemplates}};
	my $dbhTgt 			= $params{dbParams}{targetDb}{dbh};
	my $dbhInvntory 	= $params{dbParams}{inventoryDb}{dbh};
	
	Info "Starting security collection ..." ;
	
	foreach my $tpl (@sqltemplates) {
		if(defined($tpl->{ignore}) && ($tpl->{ignore} eq 'Y' ||$tpl->{ignore} eq 'y')) {
			MyWarn "Skipping template " . $tpl->{file} , 2 ;
			next;
		}
		Info "Taking care of template " . $tpl->{file} , 2 ;
		my $fileContent = read_file($tpl->{file});
		
		my $inventoryServerName = $params{dbParams}{inventoryDb}{Host} ;
		my $tgtDbName = $params{dbParams}{targetDb}{DbName};
		my $debugStr = 0; 
		
		if(!$inventoryServerName) {
			$inventoryServerName = "";
		}
		
		if(!$tgtDbName) {
			$tgtDbName = "";
		}
	
		if($DEBUG) {
			$debugStr = 1;
		}
		
		my %replacements = ("<INVENTORY_SERVERNAME>" => $inventoryServerName, "<ANALYSIS_DBNAME>" => $tgtDbName ,"<DEBUG>" => $debugStr);
		$fileContent =~ s/(@{[join "|", keys %replacements]})/$replacements{$1}/g;
		# if ($DEBUG = 1) {
			# Debug "----------------------------\n" . $fileContent . "\n-------------------------------\n";
		# }
		my $sth ;
		eval {
			$sth = $dbhTgt->prepare($fileContent);
			$sth->execute();
		};
		
		if($@ || !$sth) {
			MyErr "An error occurred in statement preparation/execution.", 2 ;
			if ($DBI::errstr) {
				MyErr $DBI::errstr , 2;
			}
			
			if ($@) {
				MyErr $@,2;
			}
			
			last;
        }
	
		my $tbl ;
		my $stmts;
		while (($tbl,$stmts) = $sth->fetchrow_array) {
			if(!defined($params{stmts})) {
				$params{stmts} = ();
			}
			
			# run it on inventory server 
			eval {
				#$dbhInvntory->do($stmts) ;
				executeMultipleStatements($stmts,'[\s]*GO[\s]*',$dbhInvntory);
				#$sthStmts->execute();
				#$dbhInvntory->commit();
			};
				
			if($@) {
				MyErr "Unable to continue\n" . $@, 2 ;
				last;
			}
			push @{$params{stmts}}, $stmts;
		}
		
		if($@) {
			last ;
		}
	}
	
	if ($DEBUG == 1) {
		eval {
			open(MERGESTMTS, '>', canonpath $params{fileout_merge_statement}) ;
			print MERGESTMTS  join("\n\n",@{$params{stmts}}) ;
			close MERGESTMTS;
		};
		if($@) {
			MyErr "Unable to output merge statements to file ". $params{fileout_merge_statement};
		}
	}
	
	
	Debug "Diconnnecting from databases" ;
	
	foreach my $dbParam (keys %{$params{dbParams}}) {
        my %database = %{$params{dbParams}{$dbParam}};
        
		if($database{dbh}) {
			eval {
				$database{dbh}->disconnect();
			};
			if( $@ ) {
				MyErr "Unable to disconnect from server " . $dbParam;
			}
			else {
				Info "Disconnected from server " . $dbParam ;
			}
		}
    }
	
}

sub InitGlobals {
	return 0;
}

sub ProcessArgs {

	# recup des arguments de la ligne de commande
    Getopt::Long::Configure("bundling", "no_ignore_case");
    if (!GetOptions(
            'D'   => \$DEBUG,
			'ServerName=s' => sub { $params{dbParams}{targetDb}{Host} = $_[1] ; },
			'DbName'     => sub { $params{dbParams}{targetDb}{DbName} = $_[1] ; },
            'h|?' => sub { &pod2usage(-verbose => 2)},
            'version'   => sub { print "$programVersion\n" }
            ) || @ARGV )
    {
       

    }
	return 0;
}

sub executeMultipleStatements {
	my $sql  		= $_[0];
	my $delimiter  	= $_[1] ;
	my $dbhandler  	= $_[2] ;
	
	my @statements = ("");
	# http://stackoverflow.com/questions/1232950/perl-dbi-run-sql-script-with-multiple-statements
	#split the string into interesting pieces (i.e. tokens):
	#   ' delimits strings
	#   \ pass on the next character if inside a string
	#   ; delimits statements unless it is in a string
	#   and anything else
	# NOTE: the grep { ord } is to get rid of the nul
	# characters the split seems to be adding
	my @tokens     = split $delimiter, $sql;
	#only keep statements that are not blank
	@statements = grep { /\S/ } @tokens;

	Debug "After extraction, there are " . $#statements . " statements to execute.\nThe query string have been cut using '$delimiter' delimiter.";
	
	for my $i (0 .. $#statements) {
		eval {
			$dbhandler->do($statements[$i]) ;
			Debug "Statement $i executed successfully" ;
			Debug "Statement $i :\n" . $statements[$i] ;
		};
		if($@) {
			MyErr $@ ;
			return 1;
		}
	}
	
	return 0;
}

sub ValidateArgs {
	my $retVal = 0;
	for my $db (keys %{$params{dbParams}}) {
		if(! $params{dbParams}{$db}{Host}) {
			MyErr "No hostname defined for database with internal name \"$db\"", 1;
			$retVal++;
		}
		
		if( ($db ne "targetDb" ) && (! $params{dbParams}{$db}{DbName})) {
			MyErr "No database name defined for database with internal name \"$db\"", 1;
			$retVal++;
		}
	}	
	
	return $retVal;
}

sub preformattedPrint {
    my ($first,$mesg,$level) = @_;

    print "$first: $mesg\n" if !defined($level);
    if(defined($level)) {
        my $append = "";
        my $cnt = 0;
        while($cnt < $level) {
            $append .= "  ";
            $cnt++;
        }
        print "$first:$append. $mesg\n";
    }
}

sub Info  {my ($mesg, $level) = @_; preformattedPrint "INFO   " , $mesg, $level;}
sub MyErr  {my ($mesg, $level) = @_; preformattedPrint "ERROR  " , $mesg, $level;}
sub MyWarn {my ($mesg, $level) = @_; preformattedPrint "WARNING" , $mesg, $level;}

sub MyDie  {
    my ($mesg, $exitCode) = @_;
    
    print "ERROR-$exitCode : $mesg\n";
    exit($exitCode);
}
sub Debug  {my ($mesg) = @_; print "DEBUG: $mesg\n" if $DEBUG;}