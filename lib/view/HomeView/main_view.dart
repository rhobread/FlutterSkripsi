import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/view/HomeView/history_view.dart';
import 'package:workout_skripsi_app/view/HomeView/home_view.dart';
import 'package:workout_skripsi_app/view/HomeView/profile_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Track current page index

  final List<Widget> _pages = [const HomePage(), HistoryPage(), ProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD), // Light background
          border: Border(
            top: BorderSide(
                color: Colors.grey.shade300, width: 0.8), // Soft top border
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0, // Remove shadow
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black, // Match UI text color
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24, // Adjust icon size
          currentIndex: _selectedIndex,
          onTap: _onItemTapped, // Handle navigation
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'.tr),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'history'.tr),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'profile'.tr),
          ],
        ),
      ),
    );
  }
}
