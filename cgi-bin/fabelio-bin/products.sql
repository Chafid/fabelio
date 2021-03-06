CREATE TABLE `products` (
  `products_id` int(11) NOT NULL AUTO_INCREMENT,
  `image` varchar(200) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `desc` text NOT NULL,
  `price` varchar(20) NOT NULL,
  `insert_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `url` varchar(100) NOT NULL,
  PRIMARY KEY (`products_id`),
  UNIQUE KEY `uc` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COMMENT='latin1_swedish_ci'