-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jan 07, 2025 at 02:20 AM
-- Server version: 8.0.21
-- PHP Version: 7.4.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sani_usermanagement`
--

-- --------------------------------------------------------

--
-- Table structure for table `modules`
--

DROP TABLE IF EXISTS `modules`;
CREATE TABLE IF NOT EXISTS `modules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_id` int NOT NULL DEFAULT '0',
  `name` varchar(100) COLLATE utf8_bin NOT NULL,
  `url` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `slug` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `is_default` tinyint NOT NULL DEFAULT '0',
  `sortid` int NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `modules`
--

INSERT INTO `modules` (`id`, `parent_id`, `name`, `url`, `slug`, `status`, `is_default`, `sortid`, `created_at`) VALUES
(1, 0, 'Dashboard', '/', 'dashboard', 1, 1, 1, '2024-12-10 16:24:21'),
(2, 0, 'User management', '#', 'user-management', 1, 0, 2, '2024-12-10 16:24:21'),
(3, 2, 'Users', '/users/users_listing.php', 'users', 1, 0, 1, '2024-12-10 16:24:21'),
(4, 2, 'Roles', '/roles/roles_listing.php', 'roles', 1, 0, 2, '2024-12-10 16:24:21');

-- --------------------------------------------------------

--
-- Table structure for table `rights`
--

DROP TABLE IF EXISTS `rights`;
CREATE TABLE IF NOT EXISTS `rights` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `rights`
--

INSERT INTO `rights` (`id`, `name`) VALUES
(2, 'Add'),
(4, 'Delete'),
(3, 'Edit'),
(5, 'Export'),
(6, 'Print'),
(1, 'View');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_bin NOT NULL,
  `is_default` tinyint NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `is_default`, `status`) VALUES
(1, 'Super admin', 1, 1),
(2, 'admin', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `roles_modules_permissions`
--

DROP TABLE IF EXISTS `roles_modules_permissions`;
CREATE TABLE IF NOT EXISTS `roles_modules_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `module_id` int NOT NULL,
  `role_id` int NOT NULL,
  `is_default` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `role_has_module` (`module_id`),
  KEY `module_has_role` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `roles_modules_permissions`
--

INSERT INTO `roles_modules_permissions` (`id`, `module_id`, `role_id`, `is_default`) VALUES
(1, 1, 1, 1),
(2, 1, 2, 1),
(3, 2, 1, 1),
(4, 3, 1, 1),
(5, 4, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `roles_modules_permissions_rights`
--

DROP TABLE IF EXISTS `roles_modules_permissions_rights`;
CREATE TABLE IF NOT EXISTS `roles_modules_permissions_rights` (
  `id` int NOT NULL AUTO_INCREMENT,
  `roles_modules_permissions_id` int NOT NULL,
  `rights_id` int NOT NULL,
  `is_default` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `permissions` (`roles_modules_permissions_id`),
  KEY `rights` (`rights_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `roles_modules_permissions_rights`
--

INSERT INTO `roles_modules_permissions_rights` (`id`, `roles_modules_permissions_id`, `rights_id`, `is_default`) VALUES
(1, 1, 1, 1),
(2, 2, 1, 1),
(3, 3, 1, 1),
(4, 4, 1, 1),
(5, 5, 1, 1),
(6, 3, 2, 1),
(7, 3, 3, 1),
(8, 3, 4, 1),
(9, 4, 2, 1),
(10, 4, 3, 1),
(11, 4, 4, 1),
(12, 5, 2, 1),
(13, 5, 3, 1),
(14, 5, 4, 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8_bin DEFAULT NULL,
  `email` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `picture` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `gender_id` int DEFAULT NULL,
  `education_id` int DEFAULT NULL,
  `interests` text COLLATE utf8_bin,
  `aboutme` text COLLATE utf8_bin,
  `password` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `is_default` tinyint NOT NULL DEFAULT '0',
  `status` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone`, `email`, `picture`, `gender_id`, `education_id`, `interests`, `aboutme`, `password`, `is_default`, `status`) VALUES
(1, 'Super admin', '03327399488', 'delickate@hotmail.com', 'sani.jpg', 1, 4, '1,2,3', 'This is Sani Hyne', '25f9e794323b453885f5181f1b624d0b', 1, 1),
(3, 'myname', '00923342344322', 'abc@xy.xom', '1736176908_dotnet core versions.JPG', NULL, NULL, NULL, NULL, '$2y$10$3SA3QGNewP86leicNKRFX.OpfPdc4T3pNqRsUNCTmBSKAdDV4QtHm', 0, 1),
(4, 'test namq', '00923321211233', 'test@hotmail.com', '1736177199_dotnet core versions.JPG', NULL, NULL, NULL, NULL, '$2y$10$qbsDnlzrcEMbERaGDPIA7OhQhL/Ptp3uUhjjoJ4qkbo0pQZrhF5tW', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `users_roles`
--

DROP TABLE IF EXISTS `users_roles`;
CREATE TABLE IF NOT EXISTS `users_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `role_has_user` (`role_id`),
  KEY `user_has_role` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `users_roles`
--

INSERT INTO `users_roles` (`id`, `user_id`, `role_id`) VALUES
(1, 1, 1),
(3, 4, 2);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `roles_modules_permissions`
--
ALTER TABLE `roles_modules_permissions`
  ADD CONSTRAINT `module_has_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `role_has_module` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `roles_modules_permissions_rights`
--
ALTER TABLE `roles_modules_permissions_rights`
  ADD CONSTRAINT `permissions` FOREIGN KEY (`roles_modules_permissions_id`) REFERENCES `roles_modules_permissions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `rights` FOREIGN KEY (`rights_id`) REFERENCES `rights` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `users_roles`
--
ALTER TABLE `users_roles`
  ADD CONSTRAINT `role_has_user` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `user_has_role` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
