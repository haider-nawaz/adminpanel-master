import 'package:admin_panel/constants.dart';
import 'package:flutter/material.dart';

class CloudStorageInfo {
  final String? svgSrc, title;
  final int? numOfFiles;
  final Color? color;

  CloudStorageInfo({
    this.svgSrc,
    this.title,
    this.numOfFiles,
    this.color,
  });
}

List demoMyFiles = [
  CloudStorageInfo(
    title: "Total Users",
    numOfFiles: 3000,
    svgSrc: "assets/images/active_users.svg",
    color: primaryColor,
  ),
  CloudStorageInfo(
    title: "Verified Users",
    numOfFiles: 1330,
    svgSrc: "assets/images/active_users.svg",
    color: primaryColor,
  ),
  CloudStorageInfo(
    title: "Rejected Users",
    numOfFiles: 1328,
    svgSrc: "assets/images/active_requests.svg",
    color: const Color(0xFFA4CDFF),
  ),
  CloudStorageInfo(
    title: "Completed",
    numOfFiles: 541,
    svgSrc: "assets/images/completed_orders.svg",
    color: const Color(0xFF007EE5),
  ),
];
