
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
 final int no;
 final Widget img;
 final String title;
 final String? artist;
 final VoidCallback pressed;
  const SongTile({
    Key? key,
    required this.no,
    required this.img,
    required this.title,
    required this.artist,
    required this.pressed
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: pressed,
      child: Container(
        child: Column(
          children:[
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text("$no"),
                SizedBox(
                  width: 10,
                ),
                Container(
                  child: img,
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          title,
                          // overflow: TextOverflow.clip,
                          maxLines: 2,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        artist!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 14),
                      )
                    ],
                  ),
                ),
                // Spacer(),
              
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Divider())
          ],
        ),
      ),
    );
  }
}
