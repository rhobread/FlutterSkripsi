import 'package:flutter_application_1/service/HomeService/workoutDetails_service.dart';
import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/HomeView/home_view.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final String day;
  final int workoutId;
  final bool isWorkoutDay;
  final bool isToday;

  const WorkoutDetailsPage({
    super.key,
    required this.day,
    required this.workoutId,
    required this.isWorkoutDay,
    required this.isToday,
  });

  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsState();
}

class _WorkoutDetailsState extends State<WorkoutDetailsPage> {
  final workoutService = WorkoutdetailsService();
  final userController = Get.find<UserController>();
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final data = await workoutService.fetchWorkout(workoutId: widget.workoutId);
      setState(() {
        _exercises = data.map((e) {
          return {
            'exercise': e,
            'sets': List<Map<String, dynamic>>.from(e['sets'] as List),
            'expanded': false,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBarMessage('Error', e.toString());
    }
  }

  Future<void> _finishWorkout() async {
    setState(() => _isLoading = true);
    // Safely parse userId to int
    final rawId = userController.userId;
    final int userId = int.tryParse(rawId.toString()) ?? 0;

    final success = await workoutService.finishWorkout(
      userId: userId,
      workoutId: widget.workoutId,
      exercises: _exercises,
    );
    setState(() => _isLoading = false);

    if (success) {
      Get.to(() => HomePage());
    }
  }

  bool get _canEdit => widget.isWorkoutDay && widget.isToday && _started;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(widget.day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: List.generate(_exercises.length, (i) {
                        final item = _exercises[i];
                        final ex = item['exercise'] as Map;
                        final sets = item['sets'] as List<Map<String, dynamic>>;
                        final isWeightExercise = ex['type'] == 'weight';

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              onExpansionChanged: (open) => setState(() => item['expanded'] = open),
                              initiallyExpanded: item['expanded'],
                              collapsedBackgroundColor: Colors.white,
                              backgroundColor: Colors.white,
                              title: Text(
                                ex['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text('Type: ${ex['type']}', style: const TextStyle(color: Colors.grey)),
                              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              children: sets.map((s) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(s['set_number'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      if (isWeightExercise) ...[
                                        Container(
                                          width: 60,
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _canEdit ? Colors.white : Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(20),
                                            border: _canEdit ? Border.all(color: Colors.black, width: 1.5) : null,
                                          ),
                                          child: TextFormField(
                                            enabled: _canEdit,
                                            initialValue: s['weight_used']?.toString() ?? '',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: _canEdit ? Colors.black : Colors.grey[600]),
                                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                                            keyboardType: TextInputType.number,
                                            onChanged: (v) => s['weight_used'] = int.tryParse(v),
                                          ),
                                        ),
                                        const Text('KG', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                      Container(
                                        width: 60,
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _canEdit ? Colors.white : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(20),
                                          border: _canEdit ? Border.all(color: Colors.black, width: 1.5) : null,
                                        ),
                                        child: TextFormField(
                                          enabled: _canEdit,
                                          initialValue: s['reps']?.toString() ?? '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: _canEdit ? Colors.black : Colors.grey[600]),
                                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                                          keyboardType: TextInputType.number,
                                          onChanged: (v) => s['reps'] = int.tryParse(v),
                                        ),
                                      ),
                                      const Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (widget.isWorkoutDay && widget.isToday)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _started ? _finishWorkout : () => setState(() => _started = true),
                      child: Text(
                        _started ? 'Finish Workout' : 'Start Workout',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
