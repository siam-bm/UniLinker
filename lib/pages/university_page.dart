import 'package:flutter/material.dart';
import '../models/university.dart';
import 'university_detail_page.dart';

class UniversityPage extends StatelessWidget {
  const UniversityPage({super.key});

  List<University> _getUniversities() {
    return [
      University(
        name: 'Harvard University',
        shortName: 'Harvard',
        location: 'Cambridge, Massachusetts, USA',
        description: 'Harvard University is a private Ivy League research university in Cambridge, Massachusetts. Established in 1636, Harvard is the oldest institution of higher education in the United States and one of the most prestigious universities in the world.',
        established: '1636',
        type: 'Private',
        ranking: 1,
        topPrograms: [
          '• Business Administration',
          '• Law',
          '• Medicine',
          '• Computer Science',
          '• Economics',
        ],
        studentCount: '23,000+',
        website: 'www.harvard.edu',
      ),
      University(
        name: 'Bangladesh University of Engineering and Technology',
        shortName: 'BUET',
        location: 'Dhaka, Bangladesh',
        description: 'Bangladesh University of Engineering and Technology (BUET) is a public research university in Dhaka, Bangladesh. It is the oldest and most prestigious engineering university in Bangladesh, known for its excellence in engineering and technological education.',
        established: '1912',
        type: 'Public',
        ranking: 1,
        topPrograms: [
          '• Computer Science & Engineering',
          '• Electrical & Electronic Engineering',
          '• Mechanical Engineering',
          '• Civil Engineering',
          '• Architecture',
        ],
        studentCount: '10,000+',
        website: 'www.buet.ac.bd',
      ),
      University(
        name: 'United International University',
        shortName: 'UIU',
        location: 'Dhaka, Bangladesh',
        description: 'United International University (UIU) is a private university in Dhaka, Bangladesh. Founded in 2003, UIU is committed to providing quality education and fostering innovation in various fields of study, with a focus on technology and business.',
        established: '2003',
        type: 'Private',
        ranking: 15,
        topPrograms: [
          '• Computer Science & Engineering',
          '• Business Administration',
          '• Electrical & Electronic Engineering',
          '• Civil Engineering',
          '• English',
        ],
        studentCount: '8,000+',
        website: 'www.uiu.ac.bd',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final universities = _getUniversities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Universities'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: universities.length,
        itemBuilder: (context, index) {
          final university = universities[index];
          return _buildUniversityCard(context, university);
        },
      ),
    );
  }

  Widget _buildUniversityCard(BuildContext context, University university) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UniversityDetailPage(university: university),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          university.shortName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                university.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                university.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(context, Icons.calendar_today, 'Est. ${university.established}'),
                  _buildInfoChip(context, Icons.account_balance, university.type),
                  _buildInfoChip(context, Icons.people, university.studentCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}