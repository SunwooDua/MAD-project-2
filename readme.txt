In order to make background working for all the screens there is few thing needed to be done

1: String? backgroundImage;
2: load background upon initialization 
  @override
  void initState() {
    super.initState();
    _loadBackground(); // for background
  }

  // load background
  Future<void> _loadBackground() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('default')
            .get();

    // only when doc exist
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        // load background image
        backgroundImage = data['theme']['backgroundImage'] ?? null;
      });
    }
  }

3: after finish working on body of scaffold, wrap it with container (all of them) and add
        decoration: BoxDecoration(
          image:
              backgroundImage !=
                      null // while background image is not null
                  ? DecorationImage(
                    image:
                        backgroundImage!.startsWith('assets')
                            ? AssetImage(backgroundImage!)
                            : FileImage(
                              File(backgroundImage!),
                            ), // use backgroundImage
                    fit: BoxFit.cover,
                  )
                  : null,
        ),

4: if background does not update even after this, on appbar add this
        actions: [
          IconButton(
            onPressed: _loadBackground,
            icon: Icon(Icons.update),
          ), // refresh
        ],
