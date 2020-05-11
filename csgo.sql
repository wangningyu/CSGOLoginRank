-- phpMyAdmin SQL Dump
-- version 3.3.9
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2016 年 06 月 15 日 07:59
-- 服务器版本: 5.1.53
-- PHP 版本: 5.3.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 数据库: `csgo`
--

-- --------------------------------------------------------

--
-- 表的结构 `csgo_member`
--

CREATE TABLE IF NOT EXISTS `csgo_member` (
  `index` bigint(32) unsigned NOT NULL AUTO_INCREMENT,
  `namech` varchar(33) CHARACTER SET utf8 NOT NULL,
  `regdate` varchar(32) DEFAULT NULL,
  `regip` varchar(32) DEFAULT NULL,
  `lastdate` varchar(32) DEFAULT NULL,
  `lastip` varchar(32) DEFAULT NULL,
  `steamid` varchar(33) NOT NULL,
  `communityvisibilitystate` varchar(32) DEFAULT NULL,
  `profilestate` varchar(32) DEFAULT NULL,
  `personaname` varchar(64) DEFAULT NULL,
  `lastlogoff` varchar(64) DEFAULT NULL,
  `profileurl` varchar(64) DEFAULT NULL,
  `avatar` varchar(64) DEFAULT NULL,
  `avatarmedium` varchar(64) DEFAULT NULL,
  `avatarfull` varchar(64) DEFAULT NULL,
  `personastate` varchar(64) DEFAULT NULL,
  `realname` varchar(64) DEFAULT NULL,
  `primaryclanid` varchar(64) DEFAULT NULL,
  `timecreated` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`index`)
) ENGINE=InnoDB  DEFAULT CHARSET=gbk COMMENT='会员中心' AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `csgo_member`
--

INSERT INTO `csgo_member` (`index`, `namech`, `regdate`, `regip`, `lastdate`, `lastip`, `steamid`, `communityvisibilitystate`, `profilestate`, `personaname`, `lastlogoff`, `profileurl`, `avatar`, `avatarmedium`, `avatarfull`, `personastate`, `realname`, `primaryclanid`, `timecreated`) VALUES
(1, '当幸福来敲门', '2016-06-10', '116.30.169.122', NULL, NULL, '76561197996262681', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- 表的结构 `csgo_reg`
--

CREATE TABLE IF NOT EXISTS `csgo_reg` (
  `index` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `steamid` varchar(32) NOT NULL,
  `name` varchar(64) CHARACTER SET utf8 DEFAULT NULL,
  `access` varchar(64) DEFAULT NULL,
  `exp_date` varchar(32) DEFAULT NULL,
  `regdate` timestamp NULL DEFAULT NULL,
  `lastlogin` varchar(32) DEFAULT NULL,
  `qq` varchar(32) DEFAULT NULL,
  `ip` varchar(24) DEFAULT NULL,
  `xp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`index`,`steamid`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk AUTO_INCREMENT=1 ;

--
-- 转存表中的数据 `csgo_reg`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_admins`
--

CREATE TABLE IF NOT EXISTS `sm_admins` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `authtype` enum('steam','name','ip') NOT NULL,
  `identity` varchar(65) NOT NULL,
  `password` varchar(65) DEFAULT NULL,
  `flags` varchar(30) NOT NULL,
  `name` varchar(65) NOT NULL,
  `immunity` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk AUTO_INCREMENT=1 ;

--
-- 转存表中的数据 `sm_admins`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_admins_groups`
--

CREATE TABLE IF NOT EXISTS `sm_admins_groups` (
  `admin_id` int(10) unsigned NOT NULL,
  `group_id` int(10) unsigned NOT NULL,
  `inherit_order` int(10) NOT NULL,
  PRIMARY KEY (`admin_id`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk;

--
-- 转存表中的数据 `sm_admins_groups`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_config`
--

CREATE TABLE IF NOT EXISTS `sm_config` (
  `cfg_key` varchar(32) NOT NULL,
  `cfg_value` varchar(255) NOT NULL,
  PRIMARY KEY (`cfg_key`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk;

--
-- 转存表中的数据 `sm_config`
--

INSERT INTO `sm_config` (`cfg_key`, `cfg_value`) VALUES
('admin_version', '1.0.0.1409');

-- --------------------------------------------------------

--
-- 表的结构 `sm_cookies`
--

CREATE TABLE IF NOT EXISTS `sm_cookies` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `access` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk AUTO_INCREMENT=1 ;

--
-- 转存表中的数据 `sm_cookies`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_cookie_cache`
--

CREATE TABLE IF NOT EXISTS `sm_cookie_cache` (
  `player` varchar(65) NOT NULL,
  `cookie_id` int(10) NOT NULL,
  `value` varchar(100) DEFAULT NULL,
  `timestamp` int(11) NOT NULL,
  PRIMARY KEY (`player`,`cookie_id`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk;

--
-- 转存表中的数据 `sm_cookie_cache`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_groups`
--

CREATE TABLE IF NOT EXISTS `sm_groups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `flags` varchar(30) NOT NULL,
  `name` varchar(120) NOT NULL,
  `immunity_level` int(1) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk AUTO_INCREMENT=1 ;

--
-- 转存表中的数据 `sm_groups`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_group_immunity`
--

CREATE TABLE IF NOT EXISTS `sm_group_immunity` (
  `group_id` int(10) unsigned NOT NULL,
  `other_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`group_id`,`other_id`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk;

--
-- 转存表中的数据 `sm_group_immunity`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_group_overrides`
--

CREATE TABLE IF NOT EXISTS `sm_group_overrides` (
  `group_id` int(10) unsigned NOT NULL,
  `type` enum('command','group') NOT NULL,
  `name` varchar(32) NOT NULL,
  `access` enum('allow','deny') NOT NULL,
  PRIMARY KEY (`group_id`,`type`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk;

--
-- 转存表中的数据 `sm_group_overrides`
--


-- --------------------------------------------------------

--
-- 表的结构 `sm_overrides`
--

CREATE TABLE IF NOT EXISTS `sm_overrides` (
  `type` enum('command','group') NOT NULL,
  `name` varchar(32) NOT NULL,
  `flags` varchar(30) NOT NULL,
  PRIMARY KEY (`type`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk;

--
-- 转存表中的数据 `sm_overrides`
--

