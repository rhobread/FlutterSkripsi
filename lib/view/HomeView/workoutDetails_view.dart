import 'package:flutter_application_1/service/HomeService/workoutDetails_service.dart';
import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/HomeView/home_view.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final String day;
  final int workoutId;
  final bool isToday;
  final bool isDone;

  const WorkoutDetailsPage({
    super.key,
    required this.day,
    required this.workoutId,
    required this.isToday,
    required this.isDone
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
  bool _isSaving = false;
  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final data = await workoutService.fetchWorkout(workoutId: widget.workoutId, isDone: widget.isDone);
    setState(() {
      _exercises = data.map((e) => {
            'exercise': e,
            'sets': List<Map<String, dynamic>>.from(e['sets'] as List),
          }).toList();
      _expanded = List.filled(_exercises.length, false);
      _isLoading = false;
    });
  }

  Future<void> _finishWorkout() async {
    setState(() => _isSaving = true);
    final userId = int.tryParse(userController.userId.value.toString()) ?? 0;
    final success = await workoutService.finishWorkout(
      userId: userId,
      workoutId: widget.workoutId,
      exercises: _exercises,
    );
    setState(() => _isSaving = false);
    if (success) Get.offAll(() => HomePage());
  }

  bool get _canEdit => !widget.isDone && widget.isToday && _started;

  void _showDetailSheet(Map<String, dynamic> ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [Tab(text: 'INSTRUCTIONS'), Tab(text: 'RECORDS')],
                  indicatorColor: Colors.blue,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Markdown(
                          data: ex['description'] ?? '',
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            p: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Center(child: Text('Records for ${ex['name']}')),
                    ],
                  ),
                ),
                if (_canEdit)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildCustomButton(
                      label: 'DONE',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _finishWorkout,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCustomButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(widget.day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, i) {
                      final ex = _exercises[i]['exercise'] as Map<String, dynamic>;
                      final sets = _exercises[i]['sets'] as List<Map<String, dynamic>>;
                      final isWeight = ex['type'] == 'weight';

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _showDetailSheet(ex),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text('Type: ${ex['type']}', style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _expanded[i] = !_expanded[i]),
                                      child: Icon(
                                        _expanded[i]
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_expanded[i])
                              Column(
                                children: sets.map((s) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(s['set_number'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (isWeight) ...[
                                          _buildBox(s['weight_used'], (v) => s['weight_used'] = v),
                                          const Text('KG', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                        _buildBox(s['reps'], (v) => s['reps'] = v),
                                        const Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (!widget.isDone && widget.isToday)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildCustomButton(
                      label: _started ? 'Finish Workout' : 'Start Workout',
                      isLoading: _isSaving,
                      onPressed: _isSaving
                          ? null
                          : _started
                              ? _finishWorkout
                              : () {
                                  setState(() {
                                    _started = true;
                                    _expanded = List.filled(_exercises.length, true);
                                  });
                                },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildBox(dynamic initial, Function(int?) onChanged) {
    final enabled = _canEdit;
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        border: enabled ? Border.all(color: Colors.black, width: 1.5) : null,
      ),
      child: TextFormField(
        enabled: enabled,
        initialValue: initial?.toString() ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(color: enabled ? Colors.black : Colors.grey[600]),
        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
        keyboardType: TextInputType.number,
        onChanged: (v) => onChanged(int.tryParse(v)),
      ),
    );
  }
}
