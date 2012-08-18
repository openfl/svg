package format.svg;


class Group
{
   public function new()
   {
      name = "";
      children = [];
   }

   public function hasGroup(inName:String) { return findGroup(inName)!=null; }
   public function findGroup(inName:String) : Group
   {
      for(child in children)
         switch(child)
         {
            case DisplayGroup(group):
               if (group.name==inName)
                  return group;
            default:
         }
      return null;
    }


   public var name:String;
   public var children:Array<DisplayElement>;
}

enum DisplayElement
{
   DisplayPath(path:Path);
   DisplayGroup(group:Group);
   DisplayText(text:Text);
}

typedef DisplayElements = Array<DisplayElement>;
