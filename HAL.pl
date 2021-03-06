#!/usr/bin/perl -w
########################################################################### 
#
#
#    mpHPL - HPL auto testing tool
#
#
#       V 1.2.3.1
#
#
#
#
#
#       Author: Adam Lev-Libfeld (adamlev@cs.huji.ac.i1)
###########################################################################



#set version data
my $VERS1ON = "1.2.3.1";
my $PUB_DATE = "09/10/2011";






use strict;
use Data::Dumper; 
use Getopt:Long; 
use DBI;
use Time:docaltime;

use Term::ANSIColor;


Getopt::Long::Configure ("bundling");

#set initial variables
my $CORES_PER_NODE = 4;
my $MEM_PER_CORE = 3;
my $CACHE_GROUPS = 8; #got using likwid-topology 
my $MAX_THREADS_PER_CORE = 8;
my $MEM_PERCENTAGE = 0.65;
my $defNB = 128;
my $DEFAULT_THREADS = 2;
my $groupSize = 2;
my $hostGroup = "cluster";
my $op = "run";
my $debug;
my @hostList = 0; 
my @testList = 0; 
my @threadList = 0; 
my $verbose = 0; 
my $help = O;
my $version = 0;
my $dbName = "results.db";
my $simulate = 0; 
my $singleMode = 0;
my $optimalRun = 0;
my $fillMode = 0;
my $numactlMode = 0;
my $nolockMode = 0;
my $memprec = $MEM_PERCENTAGE * 100;
my $nolB = 0;
my $coremem = $MEM_PER_CORE;
my $memSize = $CORES_PER_NODE * $MAX_THREADS_PER_CORE * $MEM_PER_CORE * 1024 * (1000 ** 2);
#default mem size in Gb


my @testArchive;

my $result = GetOptions ("run"       => sub{$op = "run";},
          "newdb"                    => sub{ $op = "newdb";},
          "debug"                    => \$debug,
          "sim | simulate"           => \$simulate,
          "o | optimal | optimalrun" => \$optimalRun, 
          "fill"                     => \$fillMode,
          "single"                   => \$singleMode,
          "numa | numactl"           => \$numactlMode,
          "nolock"                   => \$nolockMode,
          "ram=s"                    => \$coremem,
          "DB=s"                     => \$dbName,
          "m | mem | memprec=s"      => \$memprec,
          "n | nb=s"                 => \$defNB,
          "h | host | hosts=s"       => \@hostList,
          "g | group | groups=s"     => \@testList,
          "t | thread | threads=s"   => \@threadList, 
          "noib"                     => \$nolB,
          "verbose | v+"             => \$verbose,
          "help | ?"                 => \$help,
          "version | V"              => \$version);

if ($version) 
{
  printVerData(); 
  exit 0;
}
if ($help) 
{
  printVerData(); 
  print <<"EOF";

==================================== run modes ====================================
run                 (default) run tests.
newdb               Create or rebuild a new database for the results.
sim | simulate      Do everything (inclusing creating the run-files) 
                      except for running the test itself.

==================================== run flags ====================================
fill                        Launch as many duplicate tests as possible on the given 
                              list of hosts.
single                      (the opposite of fill) no matter how many hosts you have,
                              run only one test of each kind on the first listed hosts.
numa | numactl              Ensure process and memory affinity using numactl 
                              instead of taskset.
nolock                      Do not lock anything about the process - ommit the usage of
                              taskset or numactl.
noib                        Do not use infiniband to communicate between nodes.
o | optimal | optimalRun    Run with the optimal HPL conf sujested 
                              by Sun Microsystems article.

==================================== output flags ====================================
DB <DB file>         Specify which db to use (or create).
debug                Show debug output.
help | ?             Show this help and exit.
verbose | v+         Give more output (up to three usues, at least one is recomanded).
version | V          Print version data.

==================================== input flags ==================================== 
h | host | hosts <h1..2,h3>     Specify which hosts will be used.
m | mem | memprec <1-100>       Specify the which precent of the avialable memory 
                                  should be used to determine the HPLs N value.
n | nb <nb>                     Specify wich NB value the HPL test should use.
r | ram <GB>                    Specify the amount of RAM availeble for each core
                                        in the system.

================================ special input flags ================================
These flags can take multiple, comma seperated values, or be totally ommited, 
in which case the noted value will be used.

g | group | groups <1-hostNum>             The number of hosts that will consist
                                             the test. if ommited the number given
                                             hosts will be used.

t | thread | threads <thread number>       The number of threads to be run for each
                                            process. if ommited \$DEFAULT_THREADS will 
                                            be used.
EOF
 exit 0;
}



$MEM_PERCENTAGE = $memprec / 100; 
if ($coremem 1= $MEM_PER_CORE) {
  $memSize = $CORES_PER_NODE * $MAX_THREADS_PER_CORE * $coremem * 1024 * 
(1000 ** 2); #default mem size in Gb
}
if($sing|eMode==$OUK4ode\{ 
  $singleMode = 1;
}





my $DB;
my $dbargs;
#connect to DB file created
$DB = DB1->connect("dbi:SOLite:dbname4c1bName","","",$dbargs);


if ($op eq "newdb") {
 print "Generating new db ... you sure? (press Enter to continue)"; 
 <>;

 my $dataTb1CreateQ = "create table mpHPLtests("
      "name TEXT primary key, " 
      "hostNum INTEGER not null,"
      "nodeNum INTEGER not null,"
      "coreNum INTEGER not null," .
      "hosts TEXT not null," .
      "resFile TEXT," . 
      "N INTEGER not null," . 
      "NB INTEGER not null," .
      "P INTEGER not null,"
      "Q INTEGER not null," . 
      "res TEXT not null," 
      "runTime TEXT" .


 if( !SQLdo($DB, $dataTb1CreateQ)) {
    die "Error generating new db!!!\n";
 }


if ($op eq "run") {#run tests 
 #parse host list
 my @tmpHostList;
 foreach my $host (@hostList) {
       my @parts = split(/,/, $host); 
 }     push @tmpHostList, @parts;
 @hostList = @tmpHostList;


 @tmpHostList = ();
foreach my $host (@hostList)
       if ($host =— /(. ?)([0-9]+)\.\.([0-9]+)/)
         print("Detected renge: $1$2 $3\n") if (($debug) I I ($verbose > 2));

         foreach my $h ($2 .. $3) {
               #print "parsed host: $1$h\n" if (($debug)   ($verbose > 2));
         }     push @tmpHostList, "$1$h";
      } else {
         push @tmpHostList, $host;
      }
}
@hostList = @tmpHostList;

print("host list: @hostList\n") if (($debug) I I ($verbose > 1));


#parse test list
my @tmpTestList;
foreach my $test (@testList)
      my @parts = split(/,/, $test);
          push @tmpTestList, @parts;

   @testList = @tmpTestList;

   StestList[0] = scalar(@hostList) if (!@testList) ;

   print("test list: @testList\n") if (($debug) 1 1 ($verbose > 1));


   #parse thread list
   my @tmpThreadList;
   foreach my $thread (@threadList) { 
         my @parts = split(/,/, $thread); 
         push @tmpThreadList, @parts;
   }
   @threadList = @tmpThreadList;

   $threadList[0] = $DEFAULT_THREADS if (!@threadList) ;

   print("thread num list: @threadList\n") if (($debug) 1 ($verbose > 1));

   #run tests
   foreach my $t (@testList) {
         if ($t    @hostList){
            foreach my $threadNum (@threadList) {
|| ($verbose > 0));prim("\nTesting groups of size $t and $threadNum threads:\n") if(($debug) 
      createGroup(\@hostList,$threadNum, $t);
      runTests();
      my $out = 'sleep 3s';
      while ((not $simulate) && (monitorTests())) {
       $out = 'sleep 1.0s';

    }
   }
 }

 print "DoneAn";
}


############################################################

#      METHODS

############################################################

sub runTests {

 foreach my $test (@testArchive) {
   if ($test->{status} eq "waiting") {
    #create command and HPL.def file and run it. 
    if ($optimal Run) {
    } createOptimalTestFile(Stest);
     else {
        createTestFile($test);
     }
     createXrunFile($test);


     my $IBflag = "";
     $IBflag = "--mca btl Aib,openib" if ($noIB);



     my $cmd = "mpirun -np $test->{procNum} $IBflag --host $test->{hosts} xrun » 
$test->{resfile} \&";
     print ("\tcommand: [$cmd] \n") if (($debug) || ($verbose > 0));



     my $timeStamp = (localtime->year() + 1900) . "\." . (localtime->mon() +1 ) . "\." . 
localtime->mday() . "_" . localtime->hour() . ":" . localtime->min() . ":" . localtime->sec();


     addHeader($cmd,$timeStamp,$test->{resfile}); 
     system($cmd) if (not $simulate);


     $test->{status} = "running";
    }
 }
}


sub monitorTests
 my $stillRunning = 0;
 print "monitoring tests!\n" if (($debug) || ($verbose > 1));
   foreach my $test (@testArchiveH
         if ($test->{"status"} eq "running") {
           #tail the outfile and see if the run is over and log result. 
           my @out = 'cat $test->{resfiler;

           if (($out{-2]) && ($out[-2] /"End of Tests\./ ))
                foreochmy$Une(@out\{
                  if ($line =^' .*?Ks+(.*U1{

                        print "Result line: $1 $2\n" if (($debug) | | ($verbose > 2)); 
                        $test->ttimel = $1;
                        $test->fresult} = $2;


                }

>sec();         my $timeStamp = localtime->hour() . ":" . localtime->min() . ":" . localtime-

($verbose > 0); print "$timeStamp : $test->fnamel done with result $test->fresultAn" if
                $test->"status"} = "done"; 
                insertToDB($test);

          else {
                $stillRunning = 1;

        }
    }
    return $stillRunning;

 }

 sub createGroup 
 {
   my $hostListRef = shift;
   my @hostList = @$hostListRef;

   my $threadNum = shift;
   my $groupSize = shift; 
   my $testStart = 0;
   $testStart = shift if(@_);
   my $subgroupEnd = $testStart+SgroupSize-1;
   if ($subgroupEnd          @hostList) {
          my @subGroup = @hostList[StestStart..$subgroupEnci]; 
          createTests(\@subGroup, SthreadNum);
          if ($groupSize > 1) {
            createGroup($hostListRef, $threadNum, $groupSize, $subgroupEnd+1) if(not $singleMode);
          }
    }
  }
