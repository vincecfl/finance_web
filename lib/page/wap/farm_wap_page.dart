import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:finance_web/common/color.dart';
import 'package:finance_web/generated/l10n.dart';
import 'package:finance_web/model/asset_model.dart';
import 'package:finance_web/model/lang_model.dart';
import 'package:finance_web/model/vault_model.dart';
import 'package:finance_web/provider/common_provider.dart';
import 'package:finance_web/provider/index_provider.dart';
import 'package:finance_web/router/application.dart';
import 'package:finance_web/util/common_util.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:js' as js;

import 'package:provider/provider.dart';

class FarmWapPage extends StatefulWidget {
  @override
  _FarmWapPageState createState() => _FarmWapPageState();
}

class _FarmWapPageState extends State<FarmWapPage> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  int _layoutIndex = -1;
  bool _layoutFlag = false;
  bool tronFlag = false;
  Timer _timer;
  String _depositAmount = '';
  String _withdrawAmount = '';
  String _harvestAmount = '';


  TextEditingController _depositAmountController;
  TextEditingController _withdrawAmountController;
  TextEditingController _harvestAmountController;

  int _selectAssetFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        CommonProvider.changeHomeIndex(0);
      });
    }
    _reloadAccount();
    _getVaultData();
    _getAssetData();
  }

  @override
  void dispose() {
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(750, 1334), allowFontScaling: false);
    _depositAmountController =  TextEditingController.fromValue(TextEditingValue(text: _depositAmount,
        selection: TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: _depositAmount.length))));
    _withdrawAmountController =  TextEditingController.fromValue(TextEditingValue(text: _withdrawAmount,
        selection: TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: _withdrawAmount.length))));
    _harvestAmountController =  TextEditingController.fromValue(TextEditingValue(text: _harvestAmount,
        selection: TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: _harvestAmount.length))));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MyColors.white,
      appBar: _appBarWidget(context),
      drawer: _drawerWidget(context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _mainWidget(context),
          ),
          //FooterPage(),
        ],
      ),
    );
  }

  Widget _mainWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 0, top: 0, right: 0),
      color: MyColors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: _bodyWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget(BuildContext context) {
    return Container(
      color: MyColors.white,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: _vaultRows.length,
        itemBuilder: (context, index) {
          return _bizWidget(context, _vaultRows[index], index);
        },
      ),
    );
  }

  Widget _bizWidget(BuildContext context, VaultRows item, int index) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: index == 0 ? ScreenUtil().setHeight(30) : ScreenUtil().setHeight(0)),
          !_layoutFlag ? _oneWidget(context, item, index) : (_layoutIndex == index ? _twoWidget(context, item, index) : _oneWidget(context, item, index)),
          SizedBox(height: ScreenUtil().setHeight(10)),
          SizedBox(height: index == _vaultRows.length - 1 ? ScreenUtil().setHeight(30) : ScreenUtil().setHeight(0)),
        ],
      ),
    );
  }

  Widget _oneWidget(BuildContext context, VaultRows item, int index) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(700),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(25), bottom: ScreenUtil().setHeight(25)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _topBizWidget(context, item, index, 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoWidget(BuildContext context, VaultRows item, int index) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(700),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Container(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(25), bottom: ScreenUtil().setHeight(25)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _topBizWidget(context, item, index, 2),
                    SizedBox(height: ScreenUtil().setHeight(25)),
                    _bottomBizWidget(context, item),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBizWidget(BuildContext context, VaultRows item, int index, int type) {
    return InkWell(
      onTap: () {
        setState(() {
          _layoutIndex = index;
          if (type == 1) {
            _layoutFlag = true;
          } else {
            _layoutFlag = false;
          }
          _depositAmount = '';
          _withdrawAmount = '';
          _harvestAmount = '';
        });
      },
      child: Container(
        color: MyColors.white,
        width: ScreenUtil().setWidth(700),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(30)),
              child: ClipOval(
                child: Image.asset(
                  '${item.pic1}',
                  width: ScreenUtil().setWidth(55),
                  height: ScreenUtil().setWidth(55),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(50)),
            Container(
              width: ScreenUtil().setWidth(160),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '${item.depositTokenName}',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(30),
                        color: MyColors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(8)),
                  Container(
                    child: Text(
                      '${item.depositTokenName}',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(20),
                        color: MyColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(50)),
            Container(
              width: ScreenUtil().setWidth(160),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      '${item.apy * 100}%',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(30),
                        color: MyColors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(8)),
                  Container(
                    child: Text(
                      '${S.of(context).vaultApy}',
                      style: GoogleFonts.lato(
                        fontSize: ScreenUtil().setSp(20),
                        color: MyColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(50)),
            Container(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _layoutIndex = index;
                      if (type == 1) {
                        _layoutFlag = true;
                      } else {
                        _layoutFlag = false;
                      }
                      _depositAmount = '';
                      _withdrawAmount = '';
                      _harvestAmount = '';
                    });
                  },
                  child: Container(
                    width: ScreenUtil().setWidth(60),
                    height: ScreenUtil().setWidth(60),
                    color: MyColors.blue500,
                    alignment: Alignment.center,
                    child: Icon(
                      !_layoutFlag ? CupertinoIcons.down_arrow : (_layoutIndex == index ? CupertinoIcons.up_arrow : CupertinoIcons.down_arrow),
                      size: ScreenUtil().setSp(30),
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(25)),
          ],
        ),
      ),
    );
  }

  Widget _bottomBizWidget(BuildContext context, VaultRows item) {
    return Container(
      width: ScreenUtil().setWidth(700),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(340),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${S.of(context).vaultBalance}:   8788.80 ${item.depositTokenName}',
                        style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(26),
                          color: MyColors.grey700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(side: BorderSide(width: 1.2, color: Colors.grey[300]), borderRadius: BorderRadius.all(Radius.circular(25.0))),
                      child: Container(
                        width: ScreenUtil().setWidth(280),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(30), top: ScreenUtil().setHeight(1), bottom: ScreenUtil().setHeight(1)),
                        child: TextFormField(
                          controller: _depositAmountController,
                          enableInteractiveSelection: false,
                          cursorColor: MyColors.black87,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '',
                            hintStyle: GoogleFonts.lato(
                              color: Colors.grey[500],
                              fontSize: ScreenUtil().setSp(26),
                              letterSpacing: 0.5,
                            ),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.lato(
                            color: MyColors.black87,
                            fontSize: ScreenUtil().setSp(26),
                          ),
                          inputFormatters: [MyNumberTextInputFormatter(digit:6)],
                          onChanged: (String value) {
                            if (value != null && value != '') {
                              _depositAmount = value;
                            } else {
                              _depositAmount = '';
                            }
                            setState(() {});
                          },
                          onSaved: (String value) {},
                          onEditingComplete: () {},
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Container(
                      width: ScreenUtil().setWidth(350),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _rateWidget(context, 1, 8788.80, 25),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 1, 8788.80, 50),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 1, 8788.80, 75),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 1, 8788.80, 100),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        color: MyColors.white,
                        child: Chip(
                          elevation: 2,
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(20), top: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(10), right: ScreenUtil().setWidth(20)),
                          backgroundColor: MyColors.blue500,
                          label: Text(
                            '${S.of(context).vaultDeposit}',
                            style: GoogleFonts.lato(
                              letterSpacing: 0.5,
                              color: MyColors.white,
                              fontSize: ScreenUtil().setSp(24),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(340),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${S.of(context).vaultDeposited}:   56818.46 ${item.depositTokenName}',
                        style: GoogleFonts.lato(
                          fontSize: ScreenUtil().setSp(26),
                          color: MyColors.grey700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(side: BorderSide(width: 1.2, color: Colors.grey[300]), borderRadius: BorderRadius.all(Radius.circular(25.0))),
                      child: Container(
                        width: ScreenUtil().setWidth(280),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(30), top: ScreenUtil().setHeight(1), bottom: ScreenUtil().setHeight(1)),
                        child: TextFormField(
                          controller: _withdrawAmountController,
                          enableInteractiveSelection: false,
                          cursorColor: MyColors.black87,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '',
                            hintStyle: GoogleFonts.lato(
                              color: Colors.grey[500],
                              fontSize: ScreenUtil().setSp(26),
                              letterSpacing: 0.5,
                            ),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.lato(
                            color: MyColors.black87,
                            fontSize: ScreenUtil().setSp(26),
                          ),
                          inputFormatters: [MyNumberTextInputFormatter(digit:6)],
                          onChanged: (String value) {
                            if (value != null && value != '') {
                              _withdrawAmount = value;
                            } else {
                              _withdrawAmount = '';
                            }
                            setState(() {});
                          },
                          onSaved: (String value) {},
                          onEditingComplete: () {},
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Container(
                      width: ScreenUtil().setWidth(350),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _rateWidget(context, 2, 56818.46, 25),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 2, 56818.46, 50),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 2, 56818.46, 75),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 2, 56818.46, 100),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        color: MyColors.white,
                        child: Chip(
                          elevation: 2,
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(20), top: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(10), right: ScreenUtil().setWidth(20)),
                          backgroundColor: MyColors.blue500,
                          label: Text(
                            '${S.of(context).vaultWithdraw}',
                            style: GoogleFonts.lato(
                              letterSpacing: 0.5,
                              color: MyColors.white,
                              fontSize: ScreenUtil().setSp(24),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(680),
                child: Column(
                  children: <Widget>[
                    InkWell(
                      hoverColor: MyColors.white,
                      onTap: () {
                        _showAssetFilterDialLog();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Card(
                            elevation: 0.0,
                            child: Container(
                              width: ScreenUtil().setWidth(100),
                              padding: EdgeInsets.only(left: ScreenUtil().setWidth(5), top: ScreenUtil().setHeight(8), bottom: ScreenUtil().setHeight(8), right: ScreenUtil().setWidth(5)),
                              decoration: BoxDecoration(
                                color: MyColors.blue500,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Container(
                                width: ScreenUtil().setWidth(100),
                                alignment: Alignment.center,
                                child: Text(
                                  '${_assetModels[_selectAssetFilterIndex].tokenName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(26),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(10)),
                          Container(
                            child: Text(
                              '7862.56 ${_assetModels[_selectAssetFilterIndex].tokenName}',
                              style: GoogleFonts.lato(
                                fontSize: ScreenUtil().setSp(24),
                                color: MyColors.grey700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(side: BorderSide(width: 1.2, color: Colors.grey[300]), borderRadius: BorderRadius.all(Radius.circular(25.0))),
                      child: Container(
                        width: ScreenUtil().setWidth(350),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: ScreenUtil().setWidth(30), top: ScreenUtil().setHeight(1), bottom: ScreenUtil().setHeight(1)),
                        child: TextFormField(
                          controller: _harvestAmountController,
                          enableInteractiveSelection: false,
                          cursorColor: MyColors.black87,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '',
                            hintStyle: GoogleFonts.lato(
                              color: Colors.grey[500],
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                            border: InputBorder.none,
                          ),
                          style: GoogleFonts.lato(
                            color: MyColors.black87,
                            fontSize: ScreenUtil().setSp(26),
                          ),
                          inputFormatters: [MyNumberTextInputFormatter(digit:6)],
                          onChanged: (String value) {
                            if (value != null && value != '') {
                              _harvestAmount = value;
                            } else {
                              _harvestAmount = '';
                            }
                            setState(() {});
                          },
                          onSaved: (String value) {},
                          onEditingComplete: () {},
                        ),
                      ),
                      ),
                    SizedBox(height: ScreenUtil().setHeight(10)),
                    Container(
                      width: ScreenUtil().setWidth(350),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _rateWidget(context, 3, 7862.56, 25),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 3, 7862.56, 50),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 3, 7862.56, 75),
                          SizedBox(width: ScreenUtil().setWidth(0)),
                          _rateWidget(context, 3, 7862.56, 100),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(5)),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        color: MyColors.white,
                        child: Chip(
                          elevation: 2,
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(20), top: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(10), right: ScreenUtil().setWidth(20)),
                          backgroundColor: MyColors.blue500,
                          label: Text(
                            '${S.of(context).vaultHarvest}',
                            style: GoogleFonts.lato(
                              letterSpacing: 0.5,
                              color: MyColors.white,
                              fontSize: ScreenUtil().setSp(24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rateWidget(BuildContext context, int type, double balance, int rate) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: InkWell(
        hoverColor: Colors.white,
        splashColor: Color(0x802196F3),
        highlightColor: Color(0x802196F3),
        onTap: () {
          String account = Provider.of<IndexProvider>(context, listen: false).account;
          double rateDouble = NumUtil.divide(rate, 100);
          if(account != '') {
            double value = NumUtil.multiply(balance, rateDouble);
            setState(() {
              if (type == 1) {
                _depositAmount = value.toString();
              } else if (type == 2) {
                _withdrawAmount = value.toString();
              } else if (type == 3) {
                _harvestAmount = value.toString();
              }
            });
          }
        },
        child: Container(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(15), top: ScreenUtil().setHeight(8), bottom: ScreenUtil().setHeight(8), right: ScreenUtil().setWidth(15)),
          child: Text(
            '$rate%',
            style: GoogleFonts.lato(
              letterSpacing: 0.5,
              color: Colors.blue[800],
              fontSize: ScreenUtil().setSp(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor:  MyColors.lightBg,
      elevation: 0,
      titleSpacing: 0.0,
      title: Container(
        child: Image.asset('images/aaa.png', fit: BoxFit.contain, width: ScreenUtil().setWidth(110), height: ScreenUtil().setWidth(110)),
      ),
      leading: IconButton(
        hoverColor: MyColors.white,
        icon: Container(
          margin: EdgeInsets.only(top: ScreenUtil().setHeight(5)),
          child: Icon(Icons.menu, size: ScreenUtil().setWidth(55), color: Colors.black87),
        ),
        onPressed: () {
          _scaffoldKey.currentState.openDrawer();
        },
      ),
      centerTitle: true,
    );
  }

  Widget _drawerWidget(BuildContext context) {
    int _homeIndex = CommonProvider.homeIndex;
    int langType = Provider.of<IndexProvider>(context).langType;
    String account = Provider.of<IndexProvider>(context).account;
    return Drawer(
      child: Container(
        color: MyColors.white,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            ListTile(
              title: Text(
                '${S.of(context).actionTitle0}',
                style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(32),
                  color: _homeIndex == 0 ? Colors.black : Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  CommonProvider.changeHomeIndex(0);
                });
                Application.router.navigateTo(context, 'wap/farm', transition: TransitionType.fadeIn);
              },
              leading: Icon(
                Icons.assistant,
                color: _homeIndex == 0 ? Colors.black87 : Colors.grey[700],
              ),
            ),
            ListTile(
              title:  Text(
                '${S.of(context).actionTitle1}',
                style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(32),
                  color: _homeIndex == 1 ? Colors.black : Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                setState(() {
                  CommonProvider.changeHomeIndex(1);
                });
                Application.router.navigateTo(context, 'wap/swap', transition: TransitionType.fadeIn);
              },
              leading: Icon(
                Icons.broken_image,
                color: _homeIndex == 1 ? Colors.black87 : Colors.grey[700],
              ),
            ),
            ListTile(
              title:  Text(
                '${S.of(context).actionTitle2}',
                style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(32),
                  color: _homeIndex == 2 ? Colors.black : Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                setState(() {
                  CommonProvider.changeHomeIndex(2);
                });
                Application.router.navigateTo(context, 'wap/about', transition: TransitionType.fadeIn);
              },
              leading: Icon(
                Icons.file_copy_sharp,
                color: _homeIndex == 2 ? Colors.black87 : Colors.grey[700],
              ),
            ),
            ListTile(
              title: Text(
                account == '' ? '${S.of(context).actionTitle3}' : account.substring(0, 4) + '...' + account.substring(account.length - 4, account.length),
                style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(32),
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
              },
              leading: Icon(
                Icons.account_circle,
                color: Colors.grey[700],
              ),
            ),
            ListTile(
              title: Text(
                langType == 1 ? 'English' : '简体中文',
                style: GoogleFonts.lato(
                  fontSize: ScreenUtil().setSp(32),
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                _showLangTypeDialLog();
              },
              leading: Icon(
                Icons.language,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showLangTypeDialLog() {
    List<LangModel> langModels = Provider.of<IndexProvider>(context, listen: false).langModels;
    showDialog(
      context: context,
      child: AlertDialog(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        content: Container(
          width: ScreenUtil().setWidth(400),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: langModels.length,
            itemBuilder: (context, index) {
              return _selectLangTypeItemWidget(context, index, langModels[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _selectLangTypeItemWidget(BuildContext context, int index, LangModel item) {
    int langType = Provider.of<IndexProvider>(context, listen: false).langType;
    bool flag = index == langType ? true : false;
    return InkWell(
      onTap: () {
        Provider.of<IndexProvider>(context, listen: false).changeLangType(index);
        Navigator.pop(context);
      },
      child: Container(
        width: ScreenUtil().setWidth(300),
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(200),
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
              alignment: Alignment.centerLeft,
              child: Text(
                '${item.name}',
                style: TextStyle(
                  color: !flag ? Colors.black87 : Colors.blue[800],
                  fontSize: ScreenUtil().setSp(30),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(100),
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
              alignment: Alignment.centerRight,
              child: !flag ? Container() : Icon(
                Icons.check,
                color: Colors.blue[800],
                size: ScreenUtil().setSp(35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showAssetFilterDialLog() {
    showDialog(
      context: context,
      child: AlertDialog(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        content: Container(
          width: ScreenUtil().setWidth(400),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: _assetModels.length,
            itemBuilder: (context, index) {
              return _selectAssetItemWidget(context, index, _assetModels[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _selectAssetItemWidget(BuildContext context, int index, AssetModel item) {
    bool flag = index == _selectAssetFilterIndex ? true : false;
    return InkWell(
      onTap: () {
        setState(() {
          _selectAssetFilterIndex = index;
          Navigator.pop(context);
        });
      },
      child: Container(
        width: ScreenUtil().setWidth(300),
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(200),
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
              alignment: Alignment.centerLeft,
              child: Text(
                '${item.tokenName}',
                style: TextStyle(
                  color: !flag ? Colors.black87 : Colors.blue[800],
                  fontSize: ScreenUtil().setSp(30),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(100),
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
              alignment: Alignment.centerRight,
              child: !flag ? Container() : Icon(
                Icons.check,
                color: Colors.blue[800],
                size: ScreenUtil().setSp(35),
              ),
            ),
          ],
        ),
      ),
    );
  }


  _reloadAccount() async {
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      tronFlag = js.context.hasProperty('tronWeb');
      if (tronFlag) {
        var result = js.context["tronWeb"]["defaultAddress"]["base58"];
        if (result.toString() != 'false') {
          Provider.of<IndexProvider>(context, listen: false).changeAccount(result.toString());
        } else {
          Provider.of<IndexProvider>(context, listen: false).changeAccount('');
        }
      } else {
        Provider.of<IndexProvider>(context, listen: false).changeAccount('');
      }
    });
  }

  List<VaultRows> _vaultRows = List<VaultRows>();

  _getVaultData() async {
    _vaultRows.add(VaultRows(
        id: 0,
        mineType: 1,
        depositTokenName: 'USDT',
        depositTokenType: 2,
        pic1: 'images/usdt.png',
        pic2: 'images/usdt.png',
        contractAddress: 'TPSrDszrQoHj1Ehekz52RCCB7r5jT3KBTY',
        apy: 0.1234));
    _vaultRows.add(VaultRows(
        id: 1,
        mineType: 1,
        depositTokenName: 'TRX',
        depositTokenType: 1,
        pic1: 'images/trx.png',
        pic2: 'images/trx.png',
        contractAddress: 'TPSrDszrQoHj1Ehekz52RCCB7r5jT3KBTY',
        apy: 0.2411));
    _vaultRows.add(VaultRows(
        id: 2,
        mineType: 1,
        depositTokenName: 'USDJ',
        depositTokenType: 2,
        pic1: 'images/usdj.png',
        pic2: 'images/usdj.png',
        contractAddress: 'TPSrDszrQoHj1Ehekz52RCCB7r5jT3KBTY',
        apy: 0.3611));
    _vaultRows.add(VaultRows(
        id: 3,
        mineType: 1,
        depositTokenName: 'SUN',
        depositTokenType: 2,
        pic1: 'images/sun.png',
        pic2: 'images/sun.png',
        contractAddress: 'TPSrDszrQoHj1Ehekz52RCCB7r5jT3KBTY',
        apy: 0.7956));
    _vaultRows.add(VaultRows(
        id: 4,
        mineType: 1,
        depositTokenName: 'JST',
        depositTokenType: 2,
        pic1: 'images/jst.png',
        pic2: 'images/jst.png',
        contractAddress: 'TPSrDszrQoHj1Ehekz52RCCB7r5jT3KBTY',
        apy: 0.5632));
    _vaultRows.add(VaultRows(
        id: 5,
        mineType: 1,
        depositTokenName: 'WBTT',
        depositTokenType: 2,
        pic1: 'images/wbtt.png',
        pic2: 'images/wbtt.png',
        contractAddress: 'TPSrDszrQoHj1Ehekz52RCCB7r5jT3KBTY',
        apy: 0.6512));

    setState(() {});
  }

  List<AssetModel> _assetModels = List<AssetModel>();
  _getAssetData() {
    _assetModels.add(AssetModel(id: 0, tokenName: 'SUN', tokenType: 2, precision: 18, tokenAddress: ''));
    _assetModels.add(AssetModel(id: 1, tokenName: 'TRX', tokenType: 1, precision: 6, tokenAddress: ''));
    _assetModels.add(AssetModel(id: 2, tokenName: 'USDT', tokenType: 2, precision: 6, tokenAddress: ''));
  }


}
