import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHttpPage(title: 'My Http Study Page'),
    );
  }
}

class MyHttpPage extends StatefulWidget {
  MyHttpPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHttpPageState createState() => _MyHttpPageState();
}

class _MyHttpPageState extends State<MyHttpPage> {
  String result = ''; //결과값
  List data; //리스트
  int page;
  double scrolloffset;
  TextEditingController _editingController; //검색기능
  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    scrolloffset = .0;
    // ignore: deprecated_member_use
    data = new List();
    _editingController = new TextEditingController();

    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        print('bottom');
        page++;
        getJSONData();
      }
    });
  }

  @override
  void dispose() {
    _editingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: '검색어를 입력하세요'),
        ),
      ),
      body: Container(
        child: Center(
          child: data.length == 0
              ? Text(
                  '데이터가 없습니다',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                )
              : ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Image.network(data[index]['thumbnail'],
                                height: 100, width: 100, fit: BoxFit.contain),
                            Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 150,
                                  child: Text(
                                    data[index]['title'].toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Text(
                                    '저자: ${data[index]['authors'].toString()}'),
                                Text(
                                    '저자: ${data[index]['sale_price'].toString()}'),
                                Text('저자: ${data[index]['status'].toString()}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: data.length,
                  controller: _scrollController,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          page = 1;
          data.clear();
          getJSONData();
        },
        tooltip: 'Increment',
        child: Icon(Icons.file_download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String> getJSONData() async {
    Uri uri = Uri.parse('https://dapi.kakao.com/v3/search/book?'
        'sort=accuracy&page=${page}&size=10&query=${_editingController.value.text}');

    var response = await http.get(uri,
        headers: {"Authorization": "KakaoAK e63b4236efd3ad82c10c8eb566a7f887"});
    print(response.body);
    setState(() {
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['documents'];
      data.addAll(result);
    });
    return response.body;
  }
}
