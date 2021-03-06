import 'dart:convert';

import 'package:GankFlutter/common/Constant.dart';
import 'package:GankFlutter/model/DailyResponse.dart';
import 'package:GankFlutter/pages/home/HomeBuildRows.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildDailyListView(BuildContext context, String homeData) {
  ///如果首页item的数据为空则显示加载进度条
  if (homeData == null) {
    return buildLoadingIndicator();
  } else if (homeData.split("<h1>") != null && homeData.split("<h1>").length > 1) {
    //服务器奔溃以后会返回一个网页，所以这里判断一下，只要存在类似的标签，表示奔溃了
    // <html>
    //<head><title>404 Not Found</title></head>
    //<body bgcolor="white">
    //<center><h1>404 Not Found</h1></center>
    //<hr><center>openresty</center>
    //</body>
    //</html>

    return buildExceptionIndicator("服务器异常，修复中…");
  }

  Map<String, dynamic> value;
  List content = new List();
  List banner = new List();
  List title = new List();
  value = jsonDecode(homeData);
  DailyResponse response = DailyResponse.fromJson(value);

  if (response.error) {
    return buildExceptionIndicator("网络请求错误");
  } else {
    if (response.category.length == 0) {
      return buildExceptionIndicator("这里空空的什么都没有呢...");
    } else {
      //这里多做一层循环，主要是为了将福利展示在最前面
      response.category.forEach((row) {
        if (row == '福利') {
          title.insert(0, row);
        } else {
          title.add(row);
        }
      });

      title.forEach((title) {
        if (title == '福利') {
          banner.add(response.results[title]);
        } else {
          content.addAll(response.results[title]);
        }
      });

      content.insert(0, banner);
      return buildListViewBuilder(context, content);
    }
  }
}

Widget buildListViewBuilder(context, List data) {
  return new ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(2.0),
    itemCount: data == null ? 0 : data.length,
    itemBuilder: (context, i) {
      if (i == 0) {
        return HomeBuildRows(data[i]);
      } else {
        return buildRow(context, data[i]);
      }
    },
  );
}
