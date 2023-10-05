import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presentation_app/firebase_options.dart';


Future<void> main() async {
  // Ensuring the Flutter engine is initialized for the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing Firebase with the default options for the current platform.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Running the main Flutter app.
  runApp(MyApp());
}

// The main app widget, which is stateless.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root widget for the Flutter app with Material design.
    return MaterialApp(
      // The title of the app as it appears in task managers.
      title: 'Activity Selection',
      
      // Defining the theme for the app, using blue as the primary color.
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      
      // Setting the home widget for the app.
      // Initially, it starts with the WelcomeScreen.
      home: WelcomeScreen(),
    );
  }
}


// A stateless widget representing the start screen of the app.
class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using Scaffold to create a basic material design visual layout structure.
    return Scaffold(
      // Setting an app bar with a title.
      appBar: AppBar(
        title: Text('Select Your Role'),
      ),
      // Body of the Scaffold, which contains a column of buttons.
      body: Column(
        // Centering the main axis content.
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Expanding the child to fill the available space.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // ElevatedButton is a Material Design raised button.
              child: ElevatedButton(
                // Styling the button.
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  minimumSize: Size(double.infinity, double.infinity),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  shadowColor: Colors.grey,
                  elevation: 10, // Shadow for depth
                ),
                child: Text('Presenter', style: TextStyle(fontSize: 28)),
                onPressed: () {
                  // Navigating to another screen when the button is pressed.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NameInputScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PresenterScreen extends StatelessWidget {
  final String presenterName;

  PresenterScreen({required this.presenterName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presenter Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  minimumSize: Size(double.infinity, double.infinity),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // rounded corners
                  ),
                  shadowColor: Colors.grey,
                  elevation: 10, // shadow for depth
                ),
                child: Text('Upload PDF', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                onPressed: () {
                  uploadFileToFirebase(context);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  minimumSize: Size(double.infinity, double.infinity),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // rounded corners
                  ),
                  shadowColor: Colors.grey,
                  elevation: 10, // shadow for depth
                ),
                child: Text('View Uploaded PDFs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PDFListScreen(presenterName: presenterName)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



  Future uploadFileToFirebase(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      try {
        String fileName = result.files.single.name;
        await FirebaseStorage.instance.ref('pdfs/$fileName').putFile(file);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File uploaded successfully')));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file')));
      }
    } else {
      // User canceled the picker
    }
  }

class AudienceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audience Screen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sessions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var docData = doc.data() as Map<String, dynamic>; // get document data first

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 10,
                color: Colors.green,
                margin: EdgeInsets.all(10),
                child: ListTile(
                  tileColor: Colors.green,
                  title: Text(
                    docData['presenterName'] ?? 'N/A', // access field from document data, provvide a default value
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    docData['pdfName'] ?? 'N/A', // access field from document data, provide a default value
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  onTap: () async {
                    try {
                      final dir = await getApplicationDocumentsDirectory();
                      final file = File('${dir.path}/${docData['pdfName']}'); // access field from document data

                      if (!(await file.exists())) {
                        final ref = FirebaseStorage.instance.ref('pdfs/${docData['pdfName']}'); // access field from document data
                        final data = await ref.getData();

                        if (data != null) {
                          await file.writeAsBytes(data as List<int>);
                        }
                      }

                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PDFScreen(
                                                          path: file.path,
                                                          sessionID: '${docData['presenterName']}_${docData['pdfName']}', 
                                                          presenterName: docData['presenterName'], 
                                                          pdfName: docData['pdfName'])),
                        );

                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open file')));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class PDFListScreen extends StatefulWidget {
  final String presenterName;

  PDFListScreen({required this.presenterName});

  @override
  _PDFListScreenState createState() => _PDFListScreenState();
}

class _PDFListScreenState extends State<PDFListScreen> {
  List<Reference> pdfReferences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPDFs();
  }

  void fetchPDFs() async {
    ListResult result = await FirebaseStorage.instance.ref('pdfs').listAll();
    pdfReferences = result.items;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> openPdf(Reference ref) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${ref.name}');

      if (!(await file.exists())) {
        final data = await ref.getData();
        if (data != null) {
          await file.writeAsBytes(data as List<int>);
        }
      }

      await FirebaseFirestore.instance.collection('sessions').doc('${widget.presenterName}_${ref.name}').set({
        'presenterName': widget.presenterName,
        'pdfName': ref.name,
      });

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PDFScreen(
                                            path: file.path,
                                            sessionID: '${widget.presenterName}_${ref.name}', 
                                            presenterName: widget.presenterName,
                                            pdfName: ref.name,
                                            isPresenter: true)),
      );

      await FirebaseFirestore.instance.collection('sessions').doc('${widget.presenterName}_${ref.name}').delete();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Files'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pdfReferences.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 10,
                  color: Colors.green,
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    tileColor: Colors.green,
                    title: Text(
                      pdfReferences[index].name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => openPdf(pdfReferences[index]),
                  ),
                );
              },
            ),
    );
  }
}


class PDFScreen extends StatefulWidget {
  final String path;
  final String sessionID;
  final bool isPresenter;
  final String presenterName;
  final String pdfName;

  const PDFScreen({
    Key? key,
    required this.path,
    required this.sessionID,
    required this.presenterName,
    required this.pdfName,
    this.isPresenter = false,
  }) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  int currentPage = 0;
  PDFViewController? pdfViewController;

  void saveCurrentPresenterSession(int currentPage) {
    FirebaseFirestore.instance.collection('sessions').doc(widget.sessionID).set({
      'presenterName': widget.presenterName,
      'pdfName': widget.pdfName,
      'currentPage': currentPage,
    });
  }

   @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sessions').doc(widget.sessionID).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (!snapshot.data!.exists) { // Check if the session no longer exists
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              Navigator.pop(context); // Pop the audience member out of the PDFScreen
            });
            return Container(); // Return an empty container or some other widget for the frame
          }
          
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('currentPage')) {
            currentPage = data['currentPage'] ?? 0;
            pdfViewController?.setPage(currentPage);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('PDF Viewer'),
          ),
          body: PDFView(
            filePath: widget.path,
            autoSpacing: true,
            pageSnap: true,
            swipeHorizontal: true,
            onViewCreated: (PDFViewController pdfViewController) {
              this.pdfViewController = pdfViewController;
            },
            onError: (e) {
              print(e);
            },
            onPageChanged: (int? page, int? total) {
              if (widget.isPresenter && page != null) {
                currentPage = page;
                saveCurrentPresenterSession(currentPage);
              }
            },
          ),
        );
      },
    );
  }
}


// A stateful widget for the screen where users can input their name.
class NameInputScreen extends StatefulWidget {
  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

// The state object associated with NameInputScreen.
class _NameInputScreenState extends State<NameInputScreen> {
  // Controller for the text field where users input their name.
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Using Scaffold for a basic material design visual layout structure.
    return Scaffold(
      // Setting an app bar with a title.
      appBar: AppBar(
        title: Text('Enter Your Name'),
      ),
      // Body of the Scaffold, which contains a text field for name input.
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // Centering the main axis content.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // TextField widget for name input.
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
            SizedBox(height: 20),
            // ElevatedButton to submit the name.
            ElevatedButton(
              onPressed: () {
                // Checking if the name is not empty.
                if (_nameController.text.isNotEmpty) {
                  // Navigating to the PresenterScreen with the given name.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PresenterScreen(presenterName: _nameController.text),
                    ),
                  );
                } else {
                  // Showing a snack bar message if the name is empty.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter your name!')),
                  );
                }
              },
              child: Text('Submit', style: TextStyle(fontSize: 25)),
              // Styling the button.
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                minimumSize: Size(double.infinity, 90),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                shadowColor: Colors.grey,
                elevation: 10, // Shadow for depth
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

// The state object associated with WelcomeScreen.
class _WelcomeScreenState extends State<WelcomeScreen> {
  
  @override
  void initState() {
    super.initState();
    // After a delay of 3 seconds, navigate to the StartScreen.
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StartScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using Scaffold to create a basic material design visual layout structure.
    return Scaffold(
      // Setting a white background color.
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          // Centering the main axis content.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              // Decorating the container with a rounded shape and shadow.
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              // Displaying a welcome message.
              child: Text(
                'Welcome to AixPresent',
                style: TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
