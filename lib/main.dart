import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/university_page.dart';
import 'pages/university_detail_page.dart';
import 'models/university.dart';
import 'services/deferred_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check for deferred deep link on first launch
  final deferredUniversityId = await DeferredLinkService.checkForDeferredLink();
  
  // Determine initial route
  final initialLocation = deferredUniversityId != null 
      ? '/university/$deferredUniversityId'
      : '/';
  
  print('App starting with initial location: $initialLocation');
  
  runApp(MyApp(initialLocation: initialLocation));
}

class MyApp extends StatelessWidget {
  final String initialLocation;
  
  const MyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UniLinker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      routerConfig: _createRouter(initialLocation),
    );
  }
}

// Define all universities in a central location
List<University> getAllUniversities() {
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

// GoRouter configuration for deep linking
GoRouter _createRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
      // Handle custom scheme deep links (unilinker://...)
      final uri = state.uri;
      if (uri.scheme == 'unilinker') {
        // URI structure: unilinker://university/harvard
        // host = 'university', path = '/harvard'
        // Combine them: /university/harvard
        final host = uri.host;
        final path = uri.path;
        return '/$host$path';
      }
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/universities',
        builder: (context, state) => const UniversityPage(),
      ),
      GoRoute(
        path: '/university/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']?.toLowerCase();
          final universities = getAllUniversities();

          // Find university by shortName (case-insensitive)
          final university = universities.firstWhere(
            (uni) => uni.shortName.toLowerCase() == id,
            orElse: () => universities[0], // Default to first university if not found
          );

          return UniversityDetailPage(university: university);
        },
      ),
    ],
  );
}