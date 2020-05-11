<?
    $host   = localhost;    //登录的主机名
    $dbuser = root;   		//登录的用户名
    $dbpwd  = 123456;   	//登录的用户密码
    $dbname = csgo;     	//使用的数据库名
    $conn   = mysql_connect($host,$dbuser,$dbpwd) or die("服务器连接失败！<br>原因：".mysql_error());
    mysql_select_db($dbname,$conn) or die("数据库连接失败！<br>原因：".mysql_error());
    ini_set('date.timezone','Asia/Shanghai');
    mysql_query("set names 'utf8'");
    echo ("<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />")
?>