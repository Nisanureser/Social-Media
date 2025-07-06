import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/resources/hand_gesture_detection_service.dart';
import 'package:social_media/widgets/post_widgets/post_card.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Feed sayfasına dışarıdan erişim için global key
final GlobalKey<_FeedState> feedGlobalKey = GlobalKey<_FeedState>();

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  late Future<QuerySnapshot> future;
  // Şu anki görünür post kartları
  final List<GlobalKey<PostCardState>> _postCardKeys = [];
  // Her postun görünürlüğünü takip etmek için
  final Map<String, bool> _postVisibility = {};
  // En çok görünür olan post indeksi (scroll edildiğinde ekranda en çok görünen post)
  int _mostVisiblePostIndex = 0;
  // El hareketi algılama özelliğinin aktif olup olmadığını takip et
  bool _showGestureDetector = false;
  // Kamera ön izleme görünürlüğünü kontrol et
  bool _showCameraPreview = false;
  // Hand gesture detection service
  final HandGestureDetectionService _gestureService =
      HandGestureDetectionService();
  // Scroll Controller
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    future = fetchPosts();
    // El hareketi algılama hizmetini başlat
    _initGestureService();
  }

  Future<void> _initGestureService() async {
    await _gestureService.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _gestureService.stopDetection();
    _gestureService.dispose();
    super.dispose();
  }

  Future<QuerySnapshot> fetchPosts() {
    return FirebaseFirestore.instance
        .collection("Posts")
        .orderBy("publishDate", descending: true)
        .where("verified", isEqualTo: true)
        .get();
  }

  Future<void> _onRefresh() async {
    setState(() {
      future = fetchPosts();
      _postCardKeys.clear();
      _postVisibility.clear();
      _mostVisiblePostIndex = 0;
    });
  }

  // Post'un görünürlüğünü güncelle
  void _updatePostVisibility(int index, double visibleFraction) {
    // Görünürlük oranı 0.5'den fazla olan postu en görünür post olarak işaretle
    if (visibleFraction > 0.5 && _mostVisiblePostIndex != index) {
      print(
          'En çok görünen post değişti: $index (Görünürlük oranı: ${visibleFraction.toStringAsFixed(2)})');
      setState(() {
        _mostVisiblePostIndex = index;
      });
    }
  }

  // Görüntüde olan postları beğen - ekranda en çok görünen postu beğenecek
  void likeFirstVisiblePost() {
    if (_postCardKeys.isEmpty) {
      print('Beğenilecek post bulunamadı, _postCardKeys boş');
      return;
    }

    print('El hareketiyle beğeni işlemi başlatılıyor');

    // Ekranda en çok görünen postu beğen
    if (_mostVisiblePostIndex >= 0 &&
        _mostVisiblePostIndex < _postCardKeys.length &&
        _postCardKeys[_mostVisiblePostIndex].currentState != null) {
      print(
          'En çok görünen post için beğeni işlemi uygulanıyor (index: $_mostVisiblePostIndex)');
      _postCardKeys[_mostVisiblePostIndex].currentState!.handleLike();
    } else {
      print('Görünür post bulunamadı');
    }
  }

  // El hareketini başlat/durdur
  void _toggleGestureDetection() {
    setState(() {
      _showGestureDetector = !_showGestureDetector;
      _showCameraPreview = _showGestureDetector;
    });

    if (_showGestureDetector) {
      // El hareketi algılamayı başlat
      _gestureService.startDetection((gesture) {
        if (gesture == HandGestureType.like) {
          likeFirstVisiblePost();
        }
      });
    } else {
      // El hareketi algılamayı durdur
      _gestureService.stopDetection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: textFieldColor,
          elevation: 0,
          title: Center(
              child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text(
              "SOCİAL",
              style: TextStyle(
                fontFamily: "Header",
                fontSize: 40,
              ),
            ),
          )),
          actions: [
            IconButton(
              icon: Icon(
                _showGestureDetector
                    ? Icons.back_hand
                    : Icons.back_hand_outlined,
                color: _showGestureDetector ? Colors.blue : Colors.white,
              ),
              onPressed: _toggleGestureDetection,
            ),
          ],
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _onRefresh,
              child: FutureBuilder(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Icon(Icons.error));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("Hiç gönderi yok"));
                    }

                    // Liste oluşturulurken mevcut postCard anahtarlarını temizle
                    _postCardKeys.clear();

                    return SafeArea(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // Her bir post için bir key oluşturuyoruz
                          GlobalKey<PostCardState> key =
                              GlobalKey<PostCardState>();
                          _postCardKeys.add(key);

                          // Postun görünürlüğünü takip etmek için VisibilityDetector kullan
                          return VisibilityDetector(
                            key: Key('post_visibility_$index'),
                            onVisibilityChanged: (VisibilityInfo info) {
                              _updatePostVisibility(
                                  index, info.visibleFraction);
                            },
                            child: PostCard(
                                key: key,
                                snap: snapshot.data!.docs[index].data()),
                          );
                        },
                      ),
                    );
                  }),
            ),
            // Kamera ön izleme - sadece el hareketi algılama aktifken görünecek
            if (_showCameraPreview)
              Positioned(
                top: 60,
                right: 10,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _gestureService.getCameraPreviewWidget(),
                ),
              ),
          ],
        ));
  }
}
