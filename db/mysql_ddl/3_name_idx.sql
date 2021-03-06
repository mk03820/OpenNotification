/*==============================================================*/
/* Database name:  paging                                       */
/* DBMS name:      MySQL 3.23                                   */
/* Created on:     5/22/2004 4:55:14 PM                         */
/*==============================================================*/

use paging;

/*==============================================================*/
/* Index: name_idx                                              */
/*==============================================================*/
create index name_idx on user_data
(
   fname,
   lname,
   user_type
);