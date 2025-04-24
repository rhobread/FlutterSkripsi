import 'package:flutter_application_1/service/HomeService/workoutDetails_service.dart';
import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:flutter_application_1/view/HomeView/main_view.dart';
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
    required this.isDone,
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
    final data = await workoutService.fetchWorkout(
      workoutId: widget.workoutId,
      isDone: widget.isDone,
    );
    setState(() {
      _exercises = data
          .map((e) => {
                'exercise': e,
                'sets': List<Map<String, dynamic>>.from(e['sets'] as List),
              })
          .toList();
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
    if (success) Get.offAll(() => MainPage());
  }

  bool get _canEdit => !widget.isDone && widget.isToday && _started;

  Future<void> _showDetailSheet(int exerciseId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.75,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: workoutService.getDescription(exerciseId: exerciseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Error loading details'));
            }

            final ex = snapshot.data!;
            final List<String> types = (ex['types'] as List).cast<String>();
            final String description = (ex['description'] ?? '').toString();
            final String imagePath = ex['image'] ?? '';
            final String name = ex['name'] ?? '';
            final String equipment = types.contains('weight') ? 'Dumbbell' : 'Bodyweight';

            final bool hasDescription = description.trim().isNotEmpty;

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'INSTRUCTIONS'),
                            Tab(text: 'RECORDS'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // INSTRUCTIONS TAB
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imagePath.isNotEmpty)
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            imagePath,
                                            fit: BoxFit.contain,
                                            height: MediaQuery.of(context).size.height * 0.2,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),

                                    if (hasDescription)
                                      MarkdownBody(
                                        data: description,
                                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                                          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                          p: const TextStyle(fontSize: 16),
                                        ),
                                      )
                                    else ...[
                                      Text(
                                        name,
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      if (types.isNotEmpty) ...[
                                        const Text(
                                          'FOCUS AREA',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          types.join(', '),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      const Text(
                                        'EQUIPMENT',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        equipment,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // RECORDS TAB
                              Center(
                                child: Text(
                                  'Records for $name',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: buildCustomButton(
                    label: 'DONE',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            );
          },
        ),
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
        title: Text(
          widget.day,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                      final int exerciseId = ex['exercise_id'];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showDetailSheet(exerciseId),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        ex['image'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => setState(() => _expanded[i] = !_expanded[i]),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex['name'],
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Type: ${ex['type']}',
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _expanded[i] = !_expanded[i]),
                                    child: Icon(
                                      _expanded[i] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_expanded[i])
                              Column(
                                children: [
                                  ...sets.map((s) {
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
                                          Text(
                                            s['set_number'].toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          if (isWeight) ...[
                                            _buildBox(s['weight_used'], (v) => s['weight_used'] = v),
                                            const Text('KG', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                          _buildBox(s['reps'], (v) => s['reps'] = v),
                                          const Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                ],
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) => onChanged(int.tryParse(v)),
      ),
    );
  }
}
