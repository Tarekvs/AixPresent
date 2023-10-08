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
                    Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
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
                child: Text('Audience', style: TextStyle(fontSize: 28)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AudienceScreen()),
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

// This class defines a stateless widget for the presenter screen.
class PresenterScreen extends StatelessWidget {
  // A final string variable to store the presenter's name.
  final String presenterName;

  // Constructor for the PresenterScreen widget. It requires a presenter name to be passed.
  PresenterScreen({required this.presenterName});

  // The build method defines the widget tree for the PresenterScreen.
  @override
  Widget build(BuildContext context) {
    // Returns a scaffold widget, which provides a basic structure for the app UI.
    return Scaffold(
      // An app bar at the top of the screen with a title.
      appBar: AppBar(
        title: Text('Presenter Screen'),
      ),
      // The main content of the screen.
      body: Column(
        // Centering the main axis content.
        mainAxisAlignment: MainAxisAlignment.center,
        // Stretching the cross axis content to fill the screen width.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // A list of child widgets for the column.
        children: <Widget>[
          // Expanded widget makes the child occupy all available space.
          Expanded(
            child: Padding(
              // Adds padding around the button.
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                // Styling the button.
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Button color.
                  onPrimary: Colors.white, // Text and icon color.
                  minimumSize: Size(double.infinity, double.infinity), // Making the button expand to fill available space.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the button.
                  ),
                  shadowColor: Colors.grey, // Color of the button's shadow.
                  elevation: 10, // The depth of the button's shadow.
                ),
                // The button's label.
                child: Text('Upload PDF', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                // Action to perform when the button is pressed.
                onPressed: () {
                  // Calls a function to upload a file to Firebase.
                  uploadFileToFirebase(context);
                },
              ),
            ),
          ),
          // Another expanded widget for the second button.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  minimumSize: Size(double.infinity, double.infinity),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.grey,
                  elevation: 10,
                ),
                child: Text('View Uploaded PDFs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // Navigates to another screen when the button is pressed.
                  Navigator.push(
                    context,
                    // Defines the screen to navigate to. It takes the presenter's name as a parameter.
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



  // This function is responsible for uploading files to Firebase.
  Future uploadFileToFirebase(BuildContext context) async {
    // Using the FilePicker library, it allows the user to pick a file.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // Specifying the type of file to pick. 'custom' allows for specific file extensions.
      type: FileType.custom,
      // Only allowing PDF files to be picked.
      allowedExtensions: ['pdf'],
    );

    // Check if a file was picked.
    if (result != null) {
      // Convert the picked file into a File object.
      File file = File(result.files.single.path!);

      try {
        // Extracting the file name from the picked file.
        String fileName = result.files.single.name;
        // Using FirebaseStorage to upload the file under the 'pdfs' directory with the original filename.
        await FirebaseStorage.instance.ref('pdfs/$fileName').putFile(file);
        // If successful, show a snackbar message indicating the success.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File uploaded successfully')));
      } catch (e) {
        // If an error occurs, print the error and show a snackbar message indicating the failure.
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file')));
      }
    } else {
      // If the user cancels the file picker, no action is taken.
    }
  }
// This class defines a stateless widget for the audience screen.
class AudienceScreen extends StatelessWidget {
  // The build method defines the widget tree for the AudienceScreen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // An app bar at the top of the screen with a title.
      appBar: AppBar(
        title: Text('Audience Screen'),
      ),
      // The main content of the screen.
      body: StreamBuilder<QuerySnapshot>(
        // Establishing a stream to listen to changes in the 'sessions' collection in Firestore.
        stream: FirebaseFirestore.instance.collection('sessions').snapshots(),
        builder: (context, snapshot) {
          // If there's an error with the snapshot, display an error message.
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          // While waiting for the snapshot to load, display a loading spinner.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Creating a list view to display the documents in the 'sessions' collection.
          return ListView.builder(
            // The number of items is equal to the number of documents in the snapshot.
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Extracting the document and its data at the current index.
              var doc = snapshot.data!.docs[index];
              var docData = doc.data() as Map<String, dynamic>;

              // Returning a card for each document.
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
                    // Displaying the 'presenterName' field from the document data or 'N/A' if it doesn't exist.
                    docData['presenterName'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    // Displaying the 'pdfName' field from the document data or 'N/A' if it doesn't exist.
                    docData['pdfName'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  // The action to perform when the list tile is tapped.
                  onTap: () async {
                    try {
                      // Getting the app's document directory.
                      final dir = await getApplicationDocumentsDirectory();
                      // Creating a file reference using the 'pdfName' from the document data.
                      final file = File('${dir.path}/${docData['pdfName']}');

                      // If the file doesn't already exist in the app's directory...
                      if (!(await file.exists())) {
                        // ...create a reference to the file in Firebase Storage.
                        final ref = FirebaseStorage.instance.ref('pdfs/${docData['pdfName']}');
                        // ...and download the file data.
                        final data = await ref.getData();

                        // If the data exists, write it to the file.
                        if (data != null) {
                          await file.writeAsBytes(data as List<int>);
                        }
                      }

                      // Navigate to the PDFScreen, passing the file path and other necessary details.
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PDFScreen(
                                                          path: file.path,
                                                          sessionID: '${docData['presenterName']}_${docData['pdfName']}', 
                                                          presenterName: docData['presenterName'], 
                                                          pdfName: docData['pdfName'])),
                        );

                    } catch (e) {
                      // If an error occurs, print the error and display a snackbar with a failure message.
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




// This class defines a stateful widget for the PDF list screen.
class PDFListScreen extends StatefulWidget {
  // A final string variable to store the presenter's name.
  final String presenterName;

  // Constructor for the PDFListScreen widget. It requires a presenter name to be passed.
  PDFListScreen({required this.presenterName});

  // Creates the mutable state for this widget.
  @override
  _PDFListScreenState createState() => _PDFListScreenState();
}

// This class defines the mutable state for the PDFListScreen widget.
class _PDFListScreenState extends State<PDFListScreen> {
  // List of references to the PDF files in Firebase Storage.
  List<Reference> pdfReferences = [];
  // Boolean to track the loading state.
  bool isLoading = true;

  // This method is called when this widget is inserted into the tree.
  @override
  void initState() {
    super.initState();
    fetchPDFs(); // Fetch the list of PDFs from Firebase Storage.
  }

  // Asynchronously fetch the list of PDFs from Firebase Storage.
  void fetchPDFs() async {
    ListResult result = await FirebaseStorage.instance.ref('pdfs').listAll();
    pdfReferences = result.items;

    // Update the state to reflect that the loading has completed.
    setState(() {
      isLoading = false;
    });
  }

  // Asynchronously open a selected PDF.
  Future<void> openPdf(Reference ref) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${ref.name}');

      // If the selected PDF doesn't already exist locally...
      if (!(await file.exists())) {
        final data = await ref.getData();
        // If the data exists, write it to the file.
        if (data != null) {
          await file.writeAsBytes(data as List<int>);
        }
      }

      // Add a document to the 'sessions' collection in Firestore with the presenter's name and the PDF name.
      await FirebaseFirestore.instance.collection('sessions').doc('${widget.presenterName}_${ref.name}').set({
        'presenterName': widget.presenterName,
        'pdfName': ref.name,
      });

      // Navigate to the PDFScreen, passing the file path and other necessary details.
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PDFScreen(
                                            path: file.path,
                                            sessionID: '${widget.presenterName}_${ref.name}', 
                                            presenterName: widget.presenterName,
                                            pdfName: ref.name,
                                            isPresenter: true)),
      );

      // After returning from the PDFScreen, delete the document from the 'sessions' collection.
      await FirebaseFirestore.instance.collection('sessions').doc('${widget.presenterName}_${ref.name}').delete();
    } catch (e) {
      // If an error occurs, print the error and display a snackbar with a failure message.
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open file')));
    }
  }

  // This method defines the widget tree for the _PDFListScreenState.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // An app bar at the top of the screen with a title.
      appBar: AppBar(
        title: Text('PDF Files'),
      ),
      // The main content of the screen.
      body: isLoading
          // If still loading, display a loading spinner.
          ? Center(child: CircularProgressIndicator())
          // Otherwise, display the list of PDFs.
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
                    // Open the selected PDF when the list tile is tapped.
                    onTap: () => openPdf(pdfReferences[index]),
                  ),
                );
              },
            ),
    );
  }
}


// This class defines a stateful widget for the PDF viewer screen.
class PDFScreen extends StatefulWidget {
  // Path to the local PDF file.
  final String path;
  // Unique session ID based on presenter name and PDF name.
  final String sessionID;
  // Boolean to determine if the current user is a presenter.
  final bool isPresenter;
  // Name of the presenter.
  final String presenterName;
  // Name of the PDF.
  final String pdfName;

  const PDFScreen({
    Key? key,
    required this.path,
    required this.sessionID,
    required this.presenterName,
    required this.pdfName,
    this.isPresenter = false, // Default value if not provided.
  }) : super(key: key);

  // Creates the mutable state for this widget.
  @override
  _PDFScreenState createState() => _PDFScreenState();
}

// This class defines the mutable state for the PDFScreen widget.
class _PDFScreenState extends State<PDFScreen> {
  // Current page number of the PDF.
  int currentPage = 0;
  // Controller for the PDF viewer.
  PDFViewController? pdfViewController;

  // Save the current session details to Firestore.
  void saveCurrentPresenterSession(int currentPage) {
    FirebaseFirestore.instance.collection('sessions').doc(widget.sessionID).set({
      'presenterName': widget.presenterName,
      'pdfName': widget.pdfName,
      'currentPage': currentPage,
    });
  }

  // This method defines the widget tree for the _PDFScreenState.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // Establishing a stream to listen to changes in the current session document in Firestore.
      stream: FirebaseFirestore.instance.collection('sessions').doc(widget.sessionID).snapshots(),
      builder: (context, snapshot) {
        // If the snapshot has data...
        if (snapshot.hasData && snapshot.data != null) {
          // If the session document no longer exists in Firestore...
          if (!snapshot.data!.exists) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              // ...pop the user out of the PDFScreen.
              Navigator.pop(context);
            });
            // Return an empty container for the current frame.
            return Container();
          }
          
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          // If the session data contains a 'currentPage' field...
          if (data != null && data.containsKey('currentPage')) {
            // ...update the currentPage variable.
            currentPage = data['currentPage'] ?? 0;
            // Set the PDF viewer to the current page.
            pdfViewController?.setPage(currentPage);
          }
        }

        return Scaffold(
          // An app bar at the top of the screen with a title.
          appBar: AppBar(
            title: Text('PDF Viewer'),
          ),
          // The main content of the screen.
          body: PDFView(
            filePath: widget.path,
            autoSpacing: true,
            pageSnap: true,
            swipeHorizontal: true,
            // Callback for when the PDFView is created.
            onViewCreated: (PDFViewController pdfViewController) {
              this.pdfViewController = pdfViewController;
            },
            // Callback for errors.
            onError: (e) {
              print(e);
            },
            // Callback for when the page changes in the PDF viewer.
            onPageChanged: (int? page, int? total) {
              // If the current user is the presenter and the page has changed...
              if (widget.isPresenter && page != null) {
                currentPage = page;
                // ...save the current session details to Firestore.
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
