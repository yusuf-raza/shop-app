
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class UserProductEditScreen extends StatefulWidget {
  const UserProductEditScreen({Key? key}) : super(key: key);

  static const routeName = '/user-product-edit-screen';

  @override
  State<UserProductEditScreen> createState() => _UserProductEditScreenState();
}

class _UserProductEditScreenState extends State<UserProductEditScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  //setting up a global key for form, so that we can set its sate via a function i.e. submit it
  final _form = GlobalKey<FormState>();

  //we have created this variable to hold all the values of Product
  var _editedProduct = ProductProvider(
      id: '',
      title: 'title',
      description: 'description',
      price: 0,
      imageUrl: 'imageUrl');

  var _isInit = true;
  var _isLoading = false;

  /*we want to have the feature that whe ever focus is shifted from image url field, the url should load.
 * right now url only loads in preview when its submitted and flutter does not have any such functionality
 * so we are doing that by listeening to _imageUrlFocus node, when ever focus is shifted from that field,
 * the preview should be previewed..
 * 1) we have set up a listener in initState*/
  @override
  void initState() {
    _imageUrlFocusNode.addListener((_updateImageUrl));

    super.initState();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener((_updateImageUrl));

    super.dispose();
  }

  //this function is going to update the UI when ever the focus is not on th _imageUrFocusNode
  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  void _submitForm() async {
    //we are getting the validate() on current state
    // that automatically validates the validator: set up on all the TextInputFields in form
    //and if its true then we will allow submitForm to save data
    final isFormValid = _form.currentState!.validate();
    if (!isFormValid) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id.isNotEmpty) {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
        Get.snackbar(
          "Product updated!",
          "",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          margin: const EdgeInsets.all(15),
        );
      } catch (error) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("an error occurred!"),
                content: Text(error.toString()),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check))
                ],
              );
            });
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      //we have changed addProduct to return Future, so that
      //we can we can halt the pop anf snackbar till the future is received
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);

        Get.snackbar(
          "Product added!",
          "",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          margin: const EdgeInsets.all(15),
        );
      } catch (error) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("an error occurred!"),
                content: Text(error.toString()),
                actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check))
                ],
              );
            });
      } finally {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop();
      }
    }
  }

  var _initValue = {
    'title': '',
    'image': '',
    'price': '',
    'description': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? productId =
          ModalRoute.of(context)!.settings.arguments as String?;

      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .getProductById(productId);
        _initValue = {
          'title': _editedProduct.title,
          'image': '',
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('edit product'),
        actions: [IconButton(onPressed: _submitForm, icon: const Icon(Icons.save))],
      ),
      body: _isLoading
          ?  Center(
              child: JumpingDotsProgressIndicator(
                fontSize: 40,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValue['title'],
                        autofocus: true,
                        decoration: const InputDecoration(
                            labelText: 'Title',
                            errorStyle: TextStyle(fontWeight: FontWeight.bold)),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _priceFocusNode.requestFocus(),
                        onSaved: (value) {
                          _editedProduct = ProductProvider(
                              isFavourite: _editedProduct.isFavourite,
                              id: _editedProduct.id,
                              title: value.toString(),
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please provide a title';
                          } else {
                            null;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue['price'],
                        decoration: const InputDecoration(labelText: 'price'),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) =>
                            _descriptionFocusNode.requestFocus(),
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          _editedProduct = ProductProvider(
                              isFavourite: _editedProduct.isFavourite,
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: int.parse(value.toString()),
                              imageUrl: _editedProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please enter a price';
                          } else {
                            return null;
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue['description'],
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(labelText: 'description'),
                        onSaved: (value) {
                          _editedProduct = ProductProvider(
                              isFavourite: _editedProduct.isFavourite,
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: value.toString(),
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please enter a description';
                          }
                          if (value.length < 10) {
                            return 'description too short';
                          } else {
                            return null;
                          }
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10))),
                            child: _imageUrlController.text.isEmpty
                                ? const Text(
                                    'no image',
                                    textAlign: TextAlign.center,
                                  )
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlController.text),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.url,
                              decoration:
                                  const InputDecoration(labelText: 'image url'),
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) => _submitForm(),
                              onSaved: (value) {
                                _editedProduct = ProductProvider(
                                    id: _editedProduct.id,
                                    title: _editedProduct.title,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: value.toString(),
                                    isFavourite: _editedProduct.isFavourite);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'please enter a URL';
                                }
                                if (!value.startsWith('http:') &&
                                    !value.startsWith('https:')) {
                                  return 'provide a valid URL';
                                }
                                if (!value.endsWith('.jpg') &&
                                    !value.endsWith('.png') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'provide a valid image URL';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
