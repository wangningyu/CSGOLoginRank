<?
    $host   = localhost;    //��¼��������
    $dbuser = root;   		//��¼���û���
    $dbpwd  = 123456;   	//��¼���û�����
    $dbname = csgo;     	//ʹ�õ����ݿ���
    $conn   = mysql_connect($host,$dbuser,$dbpwd) or die("����������ʧ�ܣ�<br>ԭ��".mysql_error());
    mysql_select_db($dbname,$conn) or die("���ݿ�����ʧ�ܣ�<br>ԭ��".mysql_error());
    ini_set('date.timezone','Asia/Shanghai');
    mysql_query("set names 'utf8'");
    echo ("<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />")
?>