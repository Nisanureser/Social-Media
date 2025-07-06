import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearcherPage extends StatefulWidget {
  const SearcherPage({super.key});

  @override
  State<SearcherPage> createState() => _SearcherPageState();
}

class _SearcherPageState extends State<SearcherPage> {
  final TextEditingController _controller = TextEditingController();
  String _searchText = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios_new_rounded),
        title: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Kullanıcı Ara",
            suffixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value.trim();
            });
          },
        ),
      ),
      body: _searchText.isEmpty
          ? const Center(child: Text("Kullanıcı aramak için yazmaya başlayın"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("username", isGreaterThanOrEqualTo: _searchText)
            .where("username", isLessThan: _searchText + 'z')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("Kullanıcı bulunamadı"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user["profilePhoto"]),
                ),
                title: Text(user["username"]),

                subtitle: null,
                onTap: () {
                },
              );
            },
          );
        },
      ),
    );
  }
}
