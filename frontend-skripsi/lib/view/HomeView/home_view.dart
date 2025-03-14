import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/service/HomeService/home_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeService = HomeService();
  final userController = Get.find<UserController>();
  List<Map<String, dynamic>> _workoutList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final workouts = await homeService.fetchWorkouts(
        context: context,
        userId: userController.userId.value,
      );

      setState(() {
        _workoutList = workouts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBarMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            "Welcome, User ${userController.userName}")), // ✅ Update dynamically
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workoutList.isEmpty
              ? const Center(child: Text("No workouts available"))
              : ListView.builder(
                  itemCount: _workoutList.length,
                  itemBuilder: (context, index) {
                    final workout = _workoutList[index];
                    final date = workout['date']; // ✅ No parsing needed
                    final exercises = workout['exercises'] as List;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          "Workout on $date", // ✅ Display it directly
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: exercises.isEmpty
                            ? const Text("No exercises in this workout")
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: exercises.map((exercise) {
                                  return Text(
                                      "- ${exercise['name']} (${exercise['duration']} min)");
                                }).toList(),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
