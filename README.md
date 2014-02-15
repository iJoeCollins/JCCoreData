# JCCoreData

Core Data stack, helper methods, and categories to make the framework easier to work with.

Uses industry best practices when accessing and passing data contexts between view controllers. Apple recommends using dependency injection when accessing the managed object contexts (MOC). JCCoreData offers multiple options in accessing this context.

1. Set view controller's MOC normally using DI.
2. Access the MOC using a JCCoreData class method "defaultContext"
3. A Category that adds a MOC property to all instances of UIViewController.

#3 is an attractive approach as it allows you to conform to Apple recommendations using dependency injection as opposed to a singleton object.  It also allows you to type less...a lot less. However because of the nature of associated objects, you may find it less appealing as it will not show up in the debugger. AFAIK.

Other common ways, include:
4. Accessing the sharedApplication instance and grabbing the context from the delegate. Apple is against this as it makes dependency management a chore. Which is why they recommend DI.
5. Getting the context from an NSManagedObject.



Remember there is no one way to do something. Which is why I recommend using a combination of the described approaches above, choosing when to use them based on the situation.



## Usage

Setup and configuration guide can be found [here](/Documentation/GUIDE.md).


## License

It is open source and distributed under the MIT License (MIT). That means you have to mention Joseph Collins as the original author of this code and reproduce the LICENSE text inside your app.

You can purchase a [Non-Attribution-License](mailto:joe@ijoe.co?subject=JCCoreData Non-Attribution-License) for $100 USD, for not having to include the LICENSE text.

I also accept sponsorship for any specific enhancements you may require. Please [contact me via email](mailto:joe@ijoe.co?subject=JCCoreData Sponsorship) for inquiries.
