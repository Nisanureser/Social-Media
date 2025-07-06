import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/utils.dart';
import 'package:social_media/resources/auth_methods.dart';
import 'package:social_media/models/user_info.dart' as model;
class UsersTag extends StatefulWidget {
  const UsersTag({super.key, required this.users, required this.addUsers});

  final List<Map> users;
  final Function(List<Map> users) addUsers;

  @override
  State<UsersTag> createState() => _UsersTagState();
}

class _UsersTagState extends State<UsersTag> {
  final TextEditingController _controller = TextEditingController();
  bool isSearching = false;
  List<Map> users = [];
  void initState() {
    super.initState();
    if (widget.users.isNotEmpty) {
      users = widget.users;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 45.0,
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextFormField(
                onChanged: (s) {
                  if (_controller.text.isNotEmpty) {
                    setState(() {
                      isSearching = true;
                    });
                  } else {
                    setState(() {
                      isSearching = false;
                    });
                  }
                },
                controller: _controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Kullanıcı Arayın...",
                  prefixIcon: Icon(
                    Icons.search_rounded,
                  ),
                ),
              ),
            ),
            isSearching
                ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .orderBy("username")
                  .startAt([_controller.text]).endAt(
                  ['${_controller.text}\uf8ff']).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    model.User user = model.User.fromSnap(snapshot.data!.docs[index]);
                    return ListTile(
                      onTap: () {
                        if (users.length < 20) {
                          users.add({
                            "username": user.username,
                            "profilePhoto": user.profilePhoto,
                            "uid": user.uid,
                          });
                          setState(() {

                          });
                        } else {
                          Utils().showSnackBar(
                              "En fazla 20 kişi ekleyebilirsiniz!",
                              context,
                              Colors.white);
                        }
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePhoto),
                      ),
                      title: Row(
                        children: [
                          Text(user.username),
                          const SizedBox(
                            width: 4.0,
                          ),


                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: snapshot.data!.docs.length,
                );
              },
            )
                : const SizedBox(),
            const SizedBox(
              height: 16.0,
            ),
            const Text("Kullanıcılar Burada Gözükür"),
            const Icon(Icons.add),
            const Divider(),
            users.isNotEmpty
                ? const Align(
              alignment: Alignment.topLeft,
              child: Text("Etiketlenen Kullanıcılar"),
            )
                : const SizedBox(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(users[index]["profilePhoto"]),
                  ),
                  title: Row(
                    children: [
                      Text(users[index]["username"]),
                      const SizedBox(
                        width: 4.0,
                      ),
                      (users[index]["verified"] == true)
                          ? const Icon(Icons.verified, color: Colors.blue, size: 16.0)
                          : const SizedBox(),

                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      users.removeAt(index);
                      setState(() {

                      });
                    },
                    icon: const Icon(
                      Icons.cancel_rounded,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        height: 50,
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(textFieldColor),
          ),
          onPressed: () {
            widget.addUsers(users);
            Navigator.pop(context);
          },
          child: const Text("Kaydet",style: TextStyle(color: waveColor),),
        ),
      ),
    );
  }
}