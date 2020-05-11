<?php
    require ('steamauth/steamauth.php');  
    
	# You would uncomment the line beneath to make it refresh the data every time the page is loaded
	// $_SESSION['steam_uptodate'] = false;
?>
<html>
<head>
	<meta charset="UTF-8">
    <title>乡巴佬CSGO登录测试</title>
</head>
<body>
<?php
	//error_reporting(E_ALL);
	error_reporting(0);
	if(!isset($_SESSION['steamid'])) 
	{

		echo "游客，请先登录！\n \n";
		steamlogin(); //login button
		
	}  
	else 
	{
		include ('steamauth/userInfo.php');

		//Protected content
		echo "欢迎玩家：" . $steamprofile['personaname'] . "</br>";
		echo "你的SteamID：" . $steamprofile['steamid'] . "</br>";
		echo "你的Communityvisibilitystate：" . $steamprofile['communityvisibilitystate'] . "</br>";
		echo "profilestate：" 	. $steamprofile['profilestate'] . "</br>";
		echo "profileurl：" 	. $steamprofile['profileurl'] . "</br>";
		echo "avatar：" 		. $steamprofile['avatar'] . "</br>";
		echo "avatarmedium：" 	. $steamprofile['avatarmedium'] . "</br>";
		echo "personastate：" 	. $steamprofile['personastate'] . "</br>";
		echo "realname：" 		. $steamprofile['realname'] . "</br>";
		echo "primaryclanid：" 	. $steamprofile['primaryclanid'] . "</br>";
		
		//echo "timecreated：" 	. $steamprofile['timecreated'] . "</br>";
		//echo "lastlogoff：" 	. $steamprofile['lastlogoff'] . "</br>";
		
		$date_time_array = getdate($steamprofile['lastlogoff']); //1311177600  1316865566
		$hours = $date_time_array["hours"];
		$minutes = $date_time_array["minutes"];
		$seconds = $date_time_array["seconds"];
		$month = $date_time_array["mon"];
		$day = $date_time_array["mday"];
		$year = $date_time_array["year"];
		echo "最后登录：$year-$month-$day $hours:$minutes:$seconds</br>";
		
		//时间戳转日期
		$date_time_array = getdate($steamprofile['timecreated']); //1311177600  1316865566
		$hours = $date_time_array["hours"];
		$minutes = $date_time_array["minutes"];
		$seconds = $date_time_array["seconds"];
		$month = $date_time_array["mon"];
		$day = $date_time_array["mday"];
		$year = $date_time_array["year"];
		echo "注册日期：$year-$month-$day $hours:$minutes:$seconds</br>";
		
		//echo "timecreated：" 	 date(”Y-m-d H:i:s”, $steamprofile['timecreated']);
		//echo "你的头像：</br>" 	. '<img src="'.$steamprofile['avatarfull'].'" title="" alt="" />'; // Display their avatar!
		logoutbutton();
		
		include ("steamauth/MySQLcfg.php");
		
		function cspub_check_steamid($steamid_tmp, $conn_tmp)
		{
			//发送sql语句，验证
			//防止sql注入攻击，变化验证逻辑
			$sql = "select steamid from csgo_member where steamid = '$steamid_tmp'";
			//echo $sql;
			$result = mysql_query($sql,$conn_tmp);
			$rowcount = mysql_num_rows($result);
			if($rowcount == 0)
			{
				mysql_close($conn_tmp);
				echo "你的帐号未注册，即将自动注册！</br>";
				return false;
			}
			
			echo "你的帐号已经注册，即将绑定Steam ID！</br>";
			return true;
		}
		
		// 自动注册玩家账号
		function cspub_reg($steamid_tm, $personaname_tmp, $communityvisibilitystate_tmp, $profilestate_tmp)
		{
		
		}

		// 检查是否注册
		cspub_check_steamid($steamprofile['steamid'], $conn);
		mysql_close($conn); 
	}    
?>  
</body>
</html>