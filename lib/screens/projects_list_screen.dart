import 'package:flutter/material.dart';
import 'package:krishi_sakhi/models/home_feed_models.dart';
import 'package:krishi_sakhi/screens/Project_Details/bottom_nav_proj.dart';
import 'package:krishi_sakhi/services/home_feed_local_storage.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  late Future<List<FarmProjectItem>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _loadProjects();
  }

  Future<List<FarmProjectItem>> _loadProjects() async {
    await HomeFeedLocalStorage.ensureSeedData();
    return HomeFeedLocalStorage.getProjects();
  }

  Future<void> _refresh() async {
    setState(() {
      _projectsFuture = _loadProjects();
    });
    await _projectsFuture;
  }

  Future<void> _deleteProject(FarmProjectItem project) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete project?'),
              content: Text(
                'Are you sure you want to delete "${project.name}"? This cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final currentProjects = await HomeFeedLocalStorage.getProjects();
    final updatedProjects =
        currentProjects.where((item) => item.id != project.id).toList();
    await HomeFeedLocalStorage.saveProjects(updatedProjects);

    if (!mounted) {
      return;
    }

    await _refresh();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${project.name} deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Farm Projects',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<FarmProjectItem>>(
          future: _projectsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        'Could not load local project data.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final projects = snapshot.data ?? const <FarmProjectItem>[];
            if (projects.isEmpty) {
              return const Center(
                child: Text(
                  'No projects available offline yet.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                itemCount: projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final needsAttention = project.priority == 'high';

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProjectScreen()),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.22),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE8F5E9),
                              const Color(0xFFF1F8E9),
                              needsAttention
                                  ? const Color(0xFFFFF3E0)
                                  : Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2E7D32,
                                      ).withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.grass_rounded,
                                      color: Color(0xFF2E7D32),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Color(0xFF1B5E20),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${project.crop} | ${project.startedLabel}',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          needsAttention
                                              ? Colors.orange.withOpacity(0.16)
                                              : const Color(
                                                0xFF2E7D32,
                                              ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      project.status,
                                      style: TextStyle(
                                        color:
                                            needsAttention
                                                ? Colors.orange.shade800
                                                : const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    tooltip: 'Project options',
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      color: Colors.grey.shade700,
                                    ),
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        await _deleteProject(project);
                                      }
                                    },
                                    itemBuilder:
                                        (context) => const [
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Delete project'),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Progress',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                  Text(
                                    '${(project.progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: LinearProgressIndicator(
                                  minHeight: 9,
                                  value: project.progress.clamp(0, 1),
                                  backgroundColor: Colors.grey.withOpacity(
                                    0.25,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    needsAttention
                                        ? Colors.orange.shade400
                                        : const Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.62),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        needsAttention
                                            ? Colors.orange.withOpacity(0.3)
                                            : const Color(
                                              0xFF4CAF50,
                                            ).withOpacity(0.22),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.water_drop_rounded,
                                      size: 18,
                                      color:
                                          needsAttention
                                              ? Colors.orange.shade700
                                              : const Color(0xFF2E7D32),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        project.irrigationNote,
                                        style: TextStyle(
                                          color:
                                              needsAttention
                                                  ? Colors.orange.shade800
                                                  : const Color(0xFF2E7D32),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
