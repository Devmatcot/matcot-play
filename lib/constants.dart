import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


//Colors
const cwhite = Color(0xFFEAEBF3);
const cblue = Color(0xFF0A3068);

//icons
const wave = "assets/icons/wave.svg";
const play = "assets/icons/player.svg";
const previous = "assets/icons/previous.svg";
const pause = "assets/icons/pause.svg";
const next = "assets/icons/next.svg";
const back = "assets/icons/back.svg";
const options = "assets/icons/options.svg";
const current = "assets/icons/record.svg";
const search = "assets/icons/search.png";
const songs = "assets/icons/list.svg";
const home = "assets/icons/home.png";
//images
const button = "assets/images/button.png";
const disk = "assets/images/disk.png";
const albumart = "assets/images/AlbumArt.jpg";
const pop = "assets/images/pop.jpg";
const hiphop = "assets/images/hiphop.jpg";
const heavymetal = "assets/images/heavymetal.jpg";
const country = "assets/images/country.jpg";
const scard = "assets/images/scard.png";
const gcard = "assets/images/gcard.png";


//ButtonWidget
Widget cbutton(String symbol) {
  return Container(
    padding: const EdgeInsets.fromLTRB(25, 25, 20, 20),
    height: 65,
    width: 65,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(button),
      ),
    ),
    child: SvgPicture.asset(symbol,
    ),
  );
}

Widget playButton(String symbol) {
  return Container(
    padding: EdgeInsets.fromLTRB(25, 25, 20, 20),
    height: 80,
    width: 80,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(button),
      ),
    ),
    child: SvgPicture.asset(symbol,
    ),
  );
}