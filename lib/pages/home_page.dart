import 'package:flutter/material.dart';
import 'university_page.dart';
import 'university_detail_page.dart';
import '../models/university.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'UniLinker',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore universities and connect with opportunities',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildQuickStats(context),
                      const SizedBox(height: 30),
                      Text(
                        'Quick Access',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureGrid(context),
                      const SizedBox(height: 30),
                      _buildFeaturedSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.school,
            value: '3',
            label: 'Universities',
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people,
            value: '41K+',
            label: 'Students',
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.book,
            value: '50+',
            label: 'Programs',
            color: const Color(0xFFEC4899),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String value, required String label, required Color color}) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.school,
          title: 'Universities',
          description: 'Explore institutions',
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UniversityPage()),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.assessment,
          title: 'Programs',
          description: 'Academic courses',
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Programs feature coming soon!')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.people,
          title: 'Students',
          description: 'Connect & network',
          gradient: const LinearGradient(
            colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Students feature coming soon!')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.event,
          title: 'Events',
          description: 'Campus activities',
          gradient: const LinearGradient(
            colors: [Color(0xFFF43F5E), Color(0xFFEF4444)],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Events feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String description, required Gradient gradient, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    final universities = _getUniversities();
    final universityColors = [
      const Color(0xFFA51C30), // Harvard crimson
      const Color(0xFF006747), // BUET green
      const Color(0xFF1E40AF), // UIU blue
    ];
    final universityIcons = [
      Icons.account_balance,
      Icons.engineering,
      Icons.school,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Universities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: universities.length,
            itemBuilder: (context, index) {
              return _buildFeaturedUniversityCard(
                context,
                university: universities[index],
                image: universityIcons[index],
                color: universityColors[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedUniversityCard(BuildContext context, {required University university, required IconData image, required Color color}) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UniversityDetailPage(university: university),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(image, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  university.shortName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        university.location.split(',').last.trim(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}