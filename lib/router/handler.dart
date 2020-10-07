import 'package:finance_web/page/pc/farm_pc_page.dart';
import 'package:finance_web/page/pc/vault_pc_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

Handler vaultPcHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return VaultPcPage();
});

Handler farmPcHandler =
Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return FarmPcPage();
});