# AixPresent

The target group for this mobile app consists of presenters and their audience. Every user
of the app can be a presenter or part of the audience. To become a presenter, the user initiates a
presentation which other users can follow. By following a presentation, the user is part of the
audience.
A presentation consists of slides that are shown in the app to the audience. When the
presenter proceeds or navigates back to a slide, the screen of the audience is updated
accordingly.
This app uses Firebase Storage and Database and enables real time upload and synchronisation

# Presenters
A user acts as a presenter when he/she initiates a presentation.
The first step for the presentation is to choose a USername and then a PDF file (or upload one) that will be shown in
the presentation. After the PDF file is selected, the presentation starts and the first slide
is shown.
The presenter has the necessary controls to navigate between slides and stop the
presentation.

# Audience
Audience members see a list of ongoing presentations. By selecting a
presentation, they become part of the audience. The app shows the current slide of the
presentation, and the screen is updated accordingly to the navigation of the presenter.
A user can at any moment leave the current session.
