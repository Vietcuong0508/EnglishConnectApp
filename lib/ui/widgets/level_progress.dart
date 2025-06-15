// class LevelProgress extends StatelessWidget {
//   const LevelProgress({
//     super.key,
//     required this.progressBarKey,
//     required this.themeColor,
//     required this.viewModel,
//   });

//   final GlobalKey<State<StatefulWidget>> progressBarKey;
//   final ThemeColors themeColor;
//   final GameViewModel viewModel;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 20,
//       left: 20,
//       right: 20,
//       child: InkWell(
//         onTap: () {
//           // Hiển thị dialog khi nhấn vào progress
//           showDialog(
//             context: context,
//             builder:
//                 (_) => AlertDialog(
//                   title: Text(Strings.progress),
//                   content: Text(
//                     "${viewModel.currentLevel + 1}/${viewModel.words.length}",
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed:
//                           () => Navigator.of(context).pop(),
//                       child: Text(Strings.ok),
//                     ),
//                   ],
//                 ),
//           );
//         },
//         child: Container(
//           key: progressBarKey,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 8,
//           ),
//           decoration: BoxDecoration(
//             color: themeColor.buttonColor,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "${Strings.progress}: ${viewModel.currentLevel + 1}/${viewModel.words.length}",
//               ),
//               SizedBox(width: 10),
//               // Hiển thị thanh tiến độ
//               LinearProgressIndicator(
//                 minHeight: 10,
//                 value:
//                     viewModel.words.isNotEmpty
//                         ? (viewModel.currentLevel + 1) /
//                             viewModel.words.length
//                         : 0.0,
//                 borderRadius: BorderRadius.circular(10),
//                 backgroundColor: themeColor.iconColor
//                     .withOpacity(0.2),
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   themeColor.iconColor,
//                 ),
//               ).expand(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
