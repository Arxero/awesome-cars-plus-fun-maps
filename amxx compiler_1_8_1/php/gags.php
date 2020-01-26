<!doctype html>
<head>
<title>Gaglist</title>
<style type="text/css">
body {
	background-color: #111111;
	width:100%;
	margin:0px auto;
}
</style><!-- your html stuff -->
<meta charset="UTF-8">
</head>
<body>
<?php

$ftp_ip="93.123.18.81"; //
$ftp_user="feruchio"; //
$ftp_pass="awesomecs29"; //


$ftp_log_path="cstrike/addons/amxmodx/logs/gag_system.log";
$temporary_file="gags.tmp";

$conn_id = ftp_connect($ftp_ip);
$login_result = ftp_login($conn_id, $ftp_user, $ftp_pass);

$local = fopen($temporary_file, "w");
$result = ftp_fget($conn_id, $local, $ftp_log_path, FTP_ASCII);

ftp_close($conn_id);


$myFile = $temporary_file;
$fh = fopen($myFile, 'r');
$theData = fread($fh, filesize($myFile));
fclose($fh);

echo '<h1 style="color:#DADADA;margin:0px;padding:0px;font-size:50px;"><center>Gaglist - Awesome Cars</center></h1>'; //NASLOV
echo "<table border=\"0\" cellpadding=\"2\" style=\"width: 100%;\">\n";
echo "<tr>\n";
echo "<td style=\"background-color: #333333; color: #DADADA; font-size: small;\">Player</td>\n";
echo "<td style=\"background-color: #333333; color: #DADADA; font-size: small;\">IP</td>\n";
echo "<td style=\"background-color: #333333; color: #DADADA; font-size: small;\">Time</td>\n";
echo "<td style=\"background-color: #333333; color: #DADADA; font-size: small;\">Gag length</td>\n";
echo "<td style=\"background-color: #333333; color: #DADADA; font-size: small;\">Gagged by</td>\n";
echo "<td style=\"background-color: #333333; color: #DADADA; font-size: small;\">Reason</td>\n";
echo "<td style=\"background-color: #333333; color: #DADADA; font-size: small;\">Type</td>\n";
echo "</tr>\n";


$file1 = $temporary_file;
$lines = file($file1);


function date_sort($a, $b) {
    $extrxtedDateA = null;
    $extrxtedDateB = null;

    $dateRegex = '/([0-9]{2}\/){2}[0-9]{4}\s-\s([0-9]{2}:){2}[0-9]{2}/';
    preg_match($dateRegex, $a, $extrxtedDateA);
    preg_match($dateRegex, $b, $extrxtedDateB);

    $format = 'm/d/Y - H:i:s';
    $aDate = DateTime::createFromFormat($format, $extrxtedDateA[0]);
    $aDate = $aDate->format('Y-m-d');
    $bDate = DateTime::createFromFormat($format, $extrxtedDateB[0]);
    $bDate = $bDate->format('Y-m-d');


    return strtotime($aDate) - strtotime($bDate);
}
usort($lines, "date_sort");

function filterUngagged($currentLine) {
    
}


$line_num = -1;
foreach($lines as $linenum => $line){
 $line_num++;
}
while($line_num > -1){
$line = $lines[$line_num];
if(strlen($line) == 1){
	$line_num--;
	continue;
}

$player = null;
$ip = null;
$time = null;
$gagLength = null;
$adminName = null;
$reason = null;
$type = null;

$playerRegex = '/(?<=PLAYER: |TARGET_NAME: ).+(?= \[IP:)/';
$ipRegex = '/((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/';
$timeRegex = '/([0-9]{2}\/){2}[0-9]{4}\s-\s([0-9]{2}:){2}[0-9]{2}/';
$gagLengthRegex = '/(?<=TIME: ).+\b/';
$adminRegex = '/(?<=ADMIN: ).+(?= \| PLAYER| \| TARGET_NAME)/';
$reasonRegex = '/(?<=REASON: ).+(?= \| TIME:)/';

preg_match($playerRegex, $line, $player);
preg_match($ipRegex, $line, $ip);
preg_match($timeRegex, $line, $time);
preg_match($gagLengthRegex, $line, $gagLength);
preg_match($adminRegex, $line, $adminName);
preg_match($reasonRegex, $line, $reason);



if (strpos($line, ' [UNGAG] ') !== false) {
    $type = 'UNGAG';
    $gagLength[0] = '';
    $reason[0] = '';
}else {
    $type = 'GAG';
}

if (empty($gagLength)) {
    $gagLength[0] = 'Permanent';
}



echo "<tr>\n";

echo "<td style=\"background-color: #eee; color: #000000; font-size: small;\">";
echo htmlspecialchars($player[0]);
echo "</td>\n";

echo "<td style=\"background-color: #eee; color: #000000; font-size: small;\">";
echo $ip[0];
echo "</td>\n";

echo "<td style=\"background-color: #eee; color: #000000; font-size: small;\">";
echo $time[0];
echo "</td>\n";

echo "<td style=\"background-color: #eee; color: #000000; font-size: small;\">";
echo $gagLength[0];
echo "</td>\n";

echo "<td style=\"background-color: #eee; color: #000000; font-size: small;\">";
echo $adminName[0];
echo "</td>\n";

echo "<td style=\"background-color: #eee; color: #000000; font-size: small;\">";
echo $reason[0];
echo "</td>\n";

echo "<td style=\"background-color: #eee; color: #000000; font-size: small;\">";
echo $type;
echo "</td>\n";



echo "</tr>\n";

$line_num--;
}
echo "</table>\n";
?>
</body>
</html>