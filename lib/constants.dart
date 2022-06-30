
import 'package:flutter/material.dart';
String kSuccess = 'success';
String kError = 'error';

Map kImageSizes = {
  "images": {
    "base_url": "http://image.tmdb.org/t/p/",
    "secure_base_url": "https://image.tmdb.org/t/p/",
    "backdrop_sizes": ["w300", "w780", "w1280", "original"],
    "logo_sizes": ["w45", "w92", "w154", "w185", "w300", "w500", "original"],
    "poster_sizes": ["w92", "w154", "w185", "w342", "w500", "w780", "original"],
    "profile_sizes": ["w45", "w185", "h632", "original"],
    "still_sizes": ["w92", "w185", "w300", "original"]
  },
  "change_keys": [
    "adult",
    "air_date",
    "also_known_as",
    "alternative_titles",
    "biography",
    "birthday",
    "budget",
    "cast",
    "certifications",
    "character_names",
    "created_by",
    "crew",
    "deathday",
    "episode",
    "episode_number",
    "episode_run_time",
    "freebase_id",
    "freebase_mid",
    "general",
    "genres",
    "guest_stars",
    "homepage",
    "images",
    "imdb_id",
    "languages",
    "name",
    "network",
    "origin_country",
    "original_name",
    "original_title",
    "overview",
    "parts",
    "place_of_birth",
    "plot_keywords",
    "production_code",
    "production_companies",
    "production_countries",
    "releases",
    "revenue",
    "runtime",
    "season",
    "season_number",
    "season_regular",
    "spoken_languages",
    "status",
    "tagline",
    "title",
    "translations",
    "tvdb_id",
    "tvrage_id",
    "type",
    "video",
    "videos"
  ]
};




bool isdark = false;
bool isCaptchaSkipped = false;

Map<String, String> headers = {
  'Referer': 'https://www.imsnsit.org/imsnsit/student_login.php',
  'User-Agent':
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Safari/537.36',
  'Host': 'www.imsnsit.org',
  'Origin': 'https://www.imsnsit.org',
  'sec-ch-ua-mobile': '?0',
  'Connection': 'keep-alive',
  'Cache-Control': 'max-age=0'
};

Color nothingFound= Color(0xffF3F1F5);
Color kSecondaryColor = Color(0xFF49B584);
Color kAttendance = Color(0xFFBFEB8C);
Color kTodo = Color(0xFFB48CE7);
Color kCirculars = Color(0xFFFDE19B);
Color kTimetable = Color(0xFFFF67A4);
Color kPink = Color(0xFFFF416C);
Color kPrimaryColor = Color(0xFF7579e7);
Color mainBlue= Color(0xff6398ff);
Color kPrimaryLightColor = Color(0xFFf8efd4);
Color blueDark=Color(0xFF7868E6);
Color kBlue=Color(0xFFB8B5FF);
const Color dAccent=  Color(0xff476072);


var document;
//List<CourseData> allCourses;


// class Styles {
//   static ThemeData themeData(bool isDarkThdaeme, BuildContext context) {
//     return ThemeData(
//       primarySwatch: Colors.red,
//       primaryColor: isDarkTheme ? Colors.black : Colors.white,
//       backgroundColor: isDarkTheme ? Colors.black : Color(0xffF1F5FB),
//       indicatorColor: kPink,
//       buttonColor: kPink,
//       hintColor: kPink,
//       highlightColor: kPink,
//       hoverColor: kPink,
//       focusColor: kPink,
//       disabledColor: Colors.grey,
//       textSelectionColor: isDarkTheme ? Colors.white : Colors.black,
//       cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
//       canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
//       brightness: isDarkTheme ? Brightness.dark : Brightness.light,
//       buttonTheme: Theme.of(context).buttonTheme.copyWith(
//           colorScheme: isDarkTheme
//               ? ColorScheme.dark(
//               secondary: Colors.grey, secondaryVariant: Colors.grey)
//               : ColorScheme.light()),
//       appBarTheme: AppBarTheme(
//         elevation: 0.0,
//       ),
//     );
//   }
// }

List months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
var st= TextStyle(

  fontSize: 14,
  fontWeight: FontWeight.bold
);
List week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

List<BoxShadow> lightShadow = [
  BoxShadow(
    color: Colors.grey[300],
    offset: Offset(4.0, 4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
  BoxShadow(
    color: Colors.grey[100],
    offset: Offset(-4.0, -4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
];
List<BoxShadow> darkShadow = [
  BoxShadow(
    color: Colors.black54,
    offset: Offset(4.0, 4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
  BoxShadow(
    color: Colors.black12,
    offset: Offset(-4.0, -4.0),
    blurRadius: 4.0,
    spreadRadius: 1.0,
  ),
];


Color darkBG = Color(0xFF1B1E2B);

// bool isdark = true;
List<BoxShadow> lightShadowTop = [
  BoxShadow(
    offset: Offset(0.0, -5.0),
    color: Colors.grey[100],
    blurRadius: 2.0, // soften the shadow
    spreadRadius: 0,
  ),
];

List<BoxShadow> darkShadowTop = [
  BoxShadow(
    offset: Offset(0.0, -5.0),
    color: Colors.black26.withOpacity(0.3),
    blurRadius: 2.0, // soften the shadow
    spreadRadius: 0,
  ),
];



