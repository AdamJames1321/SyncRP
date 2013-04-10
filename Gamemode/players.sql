-- phpMyAdmin SQL Dump
-- version 3.1.2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jan 26, 2009 at 02:35 PM
-- Server version: 5.0.45
-- PHP Version: 5.2.8

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `kudomiku`
--

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE IF NOT EXISTS `players` (
  `_Key` int(11) NOT NULL auto_increment,
  `_Name` longtext NOT NULL,
  `_Clan` longtext NOT NULL,
  `_SteamID` longtext NOT NULL,
  `_UniqueID` longtext NOT NULL,
  `_Money` longtext NOT NULL,
  `_Access` longtext NOT NULL,
  `_Donator` longtext NOT NULL,
  `_Arrested` longtext NOT NULL,
  `_Inventory` longtext NOT NULL,
  `_Blacklist` longtext NOT NULL,
  PRIMARY KEY  (`_Key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `players`
--