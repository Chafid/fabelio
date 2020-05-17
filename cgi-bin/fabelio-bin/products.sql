CREATE TABLE `products` (
  `products_id` int(11) NOT NULL AUTO_INCREMENT,
  `image` varchar(200),
  `name` varchar(100) NOT NULL,
  `desc` text NOT NULL,
  `price` varchar(20) NOT NULL,
  `insert_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
   constraint uc unique (name),
  PRIMARY KEY (`products_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='latin1_swedish_ci'
