import 'package:get/get.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_bindings.dart';
import 'package:nova/features/nova_save/presentation/pages/save_create_screen.dart';
import 'package:nova/features/nova_save/presentation/pages/save_detail_screen.dart';
import 'package:nova/features/nova_save/presentation/pages/save_goals_screen.dart';

class NovaSaveRoutes {
  static List<GetPage<dynamic>> routes = [
    GetPage(
      name: SaveGoalsScreen.path,
      page: () => const SaveGoalsScreen(),
      binding: NovaSaveBindings(),
    ),
    GetPage(
      name: SaveCreateScreen.path,
      page: () => const SaveCreateScreen(),
    ),
    GetPage(
      name: SaveDetailScreen.path,
      page: () => const SaveDetailScreen(),
    ),
  ];
}
