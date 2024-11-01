import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gourmet_app/screens/threadScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'loginScreen.dart';
import 'mapScreen.dart';
import 'myPageScreen.dart';

class UploadScreen extends StatefulWidget {
  final int selected;  // final로 변경


  UploadScreen(this.selected);  // 생성자 간소화

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late int _selectedIndex;  // null 안전성을 위해 late 사용
  Future<DocumentSnapshot>? _loadUserdata;
  int rating=0;

  List<String> imageUrls = [];  // 업로드된 이미지 URL 저장
  bool imageCheck=false;//사진선택
  bool restCheck=false;//음식점선택

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selected;
    _loadUserdata=_loadUserData();
  }

  Future<void> pickAndUploadMultipleImages() async {
    try {
      final ref = FirebaseStorage.instance.ref();
      final testRef = ref.child('test/hello.txt');

      final data = utf8.encode('Hello World!');
      await testRef.putData(data);

      final url = await testRef.getDownloadURL();
      print('Success! URL: $url');
    } catch (e) {
      print('Error: $e');
    }
    // try {
    //   print('Starting image picker...');
    //   final imagePicker = ImagePicker();
    //   final List<XFile> pickedFiles = await imagePicker.pickMultiImage(
    //     imageQuality: 50,
    //     maxHeight: 150,
    //   );
    //
    //   print('Picked files count: ${pickedFiles.length}');
    //
    //   if (pickedFiles.isEmpty) {
    //     setState(() {
    //       imageCheck = false;
    //       imageUrls = [];
    //     });
    //     return;
    //   }
    //
    //   List<String> uploadedUrls = [];
    //
    //   for (XFile imageFile in pickedFiles) {
    //     try {
    //       // 파일 존재 확인
    //       final file = File(imageFile.path);
    //       final exists = await file.exists();
    //       print('File exists at ${imageFile.path}: $exists');
    //       print('File size: ${await file.length()} bytes');
    //
    //       final fileName = '${DateTime.now().millisecondsSinceEpoch}_${uploadedUrls.length}.jpg';
    //       print('Attempting to upload file: $fileName');
    //
    //       // Storage 참조 생성 확인
    //       final storageRef = FirebaseStorage.instance
    //           .ref()
    //           .child('user_images')
    //           .child(fileName);
    //       print('Storage reference created: ${storageRef.fullPath}');
    //
    //       // 메타데이터 설정
    //       final metadata = SettableMetadata(
    //           contentType: 'image/jpeg',
    //           customMetadata: {
    //             'originalPath': imageFile.path,
    //             'uploadTime': DateTime.now().toIso8601String(),
    //           }
    //       );
    //
    //       // 업로드 시작
    //       print('Starting file upload...');
    //       final uploadTask = storageRef.putFile(file, metadata);
    //
    //       // 업로드 진행상황 모니터링
    //       uploadTask.snapshotEvents.listen(
    //             (TaskSnapshot snapshot) {
    //           print('Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes');
    //         },
    //         onError: (error) {
    //           print('Upload snapshot error: $error');
    //         },
    //       );
    //
    //       // 업로드 완료 대기
    //       final snapshot = await uploadTask;
    //       print('Upload completed. State: ${snapshot.state}');
    //
    //       if (snapshot.state == TaskState.success) {
    //         // URL 가져오기 시도
    //         try {
    //           final downloadUrl = await storageRef.getDownloadURL();
    //           print('Download URL obtained: $downloadUrl');
    //           uploadedUrls.add(downloadUrl);
    //         } catch (urlError) {
    //           print('Error getting download URL: $urlError');
    //           throw urlError;
    //         }
    //       } else {
    //         print('Upload finished but not successful. State: ${snapshot.state}');
    //       }
    //
    //     } catch (singleFileError) {
    //       print('Error processing single file: $singleFileError');
    //       // 스택 트레이스 출력
    //       print(StackTrace.current);
    //     }
    //   }
    //
    //   setState(() {
    //     imageUrls = uploadedUrls;
    //     imageCheck = uploadedUrls.isNotEmpty;
    //     print('Final state - imageCheck: $imageCheck, URLs count: ${imageUrls.length}');
    //   });
    //
    // } catch (error, stackTrace) {
    //   print('Main error in pickAndUploadMultipleImages: $error');
    //   print('Stack trace: $stackTrace');
    //   setState(() {
    //     imageCheck = false;
    //     imageUrls = [];
    //   });
    // }
  }
  // DocumentSnapshot을 반환하도록 수정
  Future<DocumentSnapshot> _loadUserData() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userUid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Gourmet",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
              onPressed: ()async{
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route)=>false,
                );
              },
              icon: Icon(Icons.logout))

        ],
      ),
      drawer: FutureBuilder<DocumentSnapshot>(
        future: _loadUserdata,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('오류가 발생했습니다: ${snapshot.error}')),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Drawer(
              child: Center(child: Text('데이터를 찾을 수 없습니다')),
            );
          }
          //준비되면 yserdata를 이용할 수 있다는것이다.
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userData["Nickname"] ?? "사용자"),
                  accountEmail: Text(userData["Email"] ?? "이메일 없음"),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("마이페이지"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPageScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      body:FutureBuilder<DocumentSnapshot>(
      future: _loadUserdata,
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('데이터를 찾을 수 없습니다'));
        }

        //준비되면 yserdata를 이용할 수 있다는것이다.
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        // ready 상태에 따라 다른 화면 보여주기
        return Container(
          padding: EdgeInsets.only(left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Text("${userData["Nickname"]}"),
              Text("새로운 리뷰글을 작성해주세요!!!"),
              //Icons.star_border:Icons.star,color: Colors.grey[700]
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4), // 버튼 간격 줄이기
                      padding: EdgeInsets.zero, // 패딩 제거
                      onPressed: (){
                        setState(() {
                          rating=1;
                        });
                      },
                      icon: rating < 1 ?Icon(Icons.star_border,color: Colors.grey[700]):Icon(Icons.star,color: Colors.grey[700])
                  ),
                  IconButton(
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4), // 버튼 간격 줄이기
                      padding: EdgeInsets.zero, // 패딩 제거
                      onPressed: (){
                        setState(() {
                          rating=2;
                        });
                      },
                      icon: rating < 2 ?Icon(Icons.star_border,color: Colors.grey[700]):Icon(Icons.star,color: Colors.grey[700])
                  ),
                  IconButton(
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4), // 버튼 간격 줄이기
                      padding: EdgeInsets.zero, // 패딩 제거
                      onPressed: (){
                        setState(() {
                          rating=3;
                        });
                      },
                      icon: rating < 3 ?Icon(Icons.star_border,color: Colors.grey[700]):Icon(Icons.star,color: Colors.grey[700])
                  ),
                  IconButton(
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4), // 버튼 간격 줄이기
                      padding: EdgeInsets.zero, // 패딩 제거
                      onPressed: (){
                        setState(() {
                          rating=4;
                        });
                      },
                      icon: rating < 4 ?Icon(Icons.star_border,color: Colors.grey[700]):Icon(Icons.star,color: Colors.grey[700])
                  ),
                  IconButton(
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4), // 버튼 간격 줄이기
                      padding: EdgeInsets.zero, // 패딩 제거
                      onPressed: (){
                        setState(() {
                          rating=5;
                        });
                      },
                      icon: rating < 5 ?Icon(Icons.star_border,color: Colors.grey[700]):Icon(Icons.star,color: Colors.grey[700])
                  ),
                ],
              ),
              TextButton(
                  onPressed: ()async{
                    pickAndUploadMultipleImages();
                  }, 
                  child: Text("사진 추가+")
              ),
              if(!imageCheck)
                Text("${imageUrls.length}"),
              if(imageCheck)
                Container(
                  height: 200,
                  child: ListView.builder(
                      itemBuilder: (contex,index){
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            width: 60,  // Container 너비에 맞춤
                            height: 150,  // Container 높이에 맞춤
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator()
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        );
                      },
                      itemCount: imageUrls.length,
                  ),
                )

            ],
          ),
        );
      },
    ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '추가',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: '그리드',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index)async{
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MapScreen(index)),
                  (route) => false,
            );
          } else if (index == 1) {
            if (_loadUserdata == null) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터를 불러오는 중입니다. 잠시만 기다려주세요.'))
            );
            return;
            }
            // 현재 _loadUserdata데이터가 있을때까지 기다리기
          final snapshot = await _loadUserdata!;
            final isStudent = (snapshot.data() as Map<String, dynamic>)["Is_student"];
          if(isStudent){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UploadScreen(index)),
                  (route) => false,
            );
          }else
            {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('알림'),
                    content: Row(
                      children: [
                        Text("일반유저",style:
                    TextStyle(
                        fontSize: 15,
                        color: Colors.red
                    ),),
                        Text('이므로 작성할 수 없습니다.',style:
                          TextStyle(
                            fontSize: 15
                          ),),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('확인'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );
            }


          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ThreadScreen(index)),
                  (route) => false,
            );
          }
        },
        showSelectedLabels: false,  // 선택된 아이템의 라벨 숨기기
        showUnselectedLabels: false,  // 선택되지 않은 아이템의 라벨 숨기기
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

