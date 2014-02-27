package harayoki.dragonbones
{
    import flash.geom.Point;
    
    import dragonBones.Bone;
    import dragonBones.Slot;
    
    import starling.display.DisplayObject;

    public class DragonBonesSortFunctions
    {
        private static const HELPER_POS:Point = new Point();
        private static const HELPER_POS_A:Point = new Point();
        private static const HELPER_POS_B:Point = new Point();
        
        private static var  _useGlobalPositionBoolean:Boolean;
        private static var _reverseX:Boolean;
        private static var _reverseY:Boolean;
        
        ////うまく動いていない
        //private static function SORT_ON_ARMATURE_POS(a:Armature,b:Armature):int
        //{
        //    var dispA:DisplayObject = a.display as DisplayObject;
        //    var dispB:DisplayObject = b.display as DisplayObject;
        //    if(dispA && dispB){
        //        HELPER_POS_A.x = dispA.x;
        //        HELPER_POS_A.y = dispA.y;
        //        HELPER_POS_B.x = dispB.x;
        //        HELPER_POS_B.y = dispB.y;
        //        if(_useGlobalPositionBoolean)
        //        {
        //            dispA.parent.localToGlobal(HELPER_POS_A,HELPER_POS);
        //            HELPER_POS_A.copyFrom(HELPER_POS);
        //            dispB.parent.localToGlobal(HELPER_POS_B,HELPER_POS);
        //            HELPER_POS_B.copyFrom(HELPER_POS);
        //        }
        //        if(HELPER_POS_A.x < HELPER_POS_B.x)
        //        {
        //            return -1 * (_reverseX ? -1 : 1);
        //        }
        //        else if(HELPER_POS_A.x > HELPER_POS_B.x)
        //        {
        //            return 1 * (_reverseX ? -1 : 1);
        //        }
        //        else
        //        {
        //            if(HELPER_POS_A.y<HELPER_POS_B.y)
        //            {
        //                return -1 * (_reverseY ? -1 : 1);
        //            }
        //            else if(HELPER_POS_A.y>HELPER_POS_B.y)
        //            {
        //                return 1 * (_reverseY ? -1 : 1);
        //            }
        //            return 0;
        //        }
        //        
        //    }
        //    else if(dispA)
        //    {
        //        return -1;
        //    }
        //    else if(dispB)
        //    {
        //        return 1;
        //    }
        //    return 0;
        //}
        
    //        /**
    //         * 左上を基準として表示位置でArmatureをソートして返す
    //         */
    //        public static function sortArmaturesByGlobalPosition(armatures:Vector.<Armature>,reverseX:Boolean=false,reverseY:Boolean=false,useGlobalPositionBoolean=true):void
    //        {
    //            _useGlobalPositionBoolean = useGlobalPositionBoolean;
    //            _reverseX = reverseX;
    //            _reverseY = reverseY;
    //            armatures.sort(SORT_ON_ARMATURE_POS);
    //        }
                
        
//        private static function SORT_ON_BONE_POS(a:Bone,b:Bone):int
//        {
//            if(a.childArmature && b.childArmature)
//            {
//                return SORT_ON_BONE_ORG_POS(a,b);
//            }
//            else if(a.childArmature)
//            {
//                return -1;
//            }
//            else if(b.childArmature)
//            {
//                return 1;
//            }
//            return 0;
//        }
//        
//        private static function SORT_ON_SLOT_POS(a:Slot,b:Slot):int
//        {
//            if(a.childArmature && b.childArmature)
//            {
//                return SORT_ON_SLOT_ORG_POS(a,b);
//            }
//            else if(a.childArmature)
//            {
//                return -1;
//            }
//            else if(b.childArmature)
//            {
//                return 1;
//            }
//            return 0;
//        }
        
        
        private static function _localToGlobal(dispA:DisplayObject,dispB:DisplayObject):void
        {
            dispA.parent.localToGlobal(HELPER_POS_A,HELPER_POS);
            HELPER_POS_A.copyFrom(HELPER_POS);
            dispB.parent.localToGlobal(HELPER_POS_B,HELPER_POS);
            HELPER_POS_B.copyFrom(HELPER_POS);
        }
        
        private static function _comparePoint(a:Point,b:Point):int
        {
            //trace(a,b);
            if(a.y<b.y)
            {
                // trace("-1 B");
                return -1 * (_reverseY ? -1 : 1);
            }
            else if(a.y>b.y)
            {
                //trace("+1 B");
                return 1 * (_reverseY ? -1 : 1);
            }
            else
            {
                if(a.x < b.x)
                {
                    //trace("-1 A");
                    return -1 * (_reverseX ? -1 : 1);
                }
                else if(a.x > b.x)
                {
                    //trace("+1 A");
                    return 1 * (_reverseX ? -1 : 1);
                }
            }
            return 0;
        }
        
        private static function SORT_ON_BONE_ORG_POS(a:Bone,b:Bone):int
        {
            var dispA:DisplayObject = a.display as DisplayObject;
            var dispB:DisplayObject = b.display as DisplayObject;
            
            if(!dispA && !dispB)
            {
                return 0;
            }
            else if(!dispB)
            {
                return -1;
            }
            else if(!dispA)
            {
                return 1;
            }
            
            HELPER_POS_A.x = a.origin.x;
            HELPER_POS_A.y = a.origin.y;
            HELPER_POS_B.x = b.origin.x;
            HELPER_POS_B.y = b.origin.y;
            
            if(_useGlobalPositionBoolean)
            {
                _localToGlobal(dispA,dispB);
            }

            return _comparePoint(HELPER_POS_A,HELPER_POS_B);
            
        }
        
        private static function SORT_ON_SLOT_ORG_POS(a:Slot,b:Slot):int
        {
            var dispA:DisplayObject = a.display as DisplayObject;
            var dispB:DisplayObject = b.display as DisplayObject;
            
            if(!dispA && !dispB)
            {
                return 0;
            }
            else if(!dispB)
            {
                return -1;
            }
            else if(!dispA)
            {
                return 1;
            }
            
            HELPER_POS_A.x = a.origin.x;
            HELPER_POS_A.y = a.origin.y;
            HELPER_POS_B.x = b.origin.x;
            HELPER_POS_B.y = b.origin.y;
            
            if(_useGlobalPositionBoolean)
            {
                _localToGlobal(dispA,dispB);
            }
            
            return _comparePoint(HELPER_POS_A,HELPER_POS_B);
            
        }

        /**
         * 左上を基準として表示位置でBoneをソートして返す
         */
        public static function sortBonesByGlobalPosition(bones:Vector.<Bone>,reverseX:Boolean=false,reverseY:Boolean=false,useGlobalPositionBoolean=true):void
        {
            _useGlobalPositionBoolean = useGlobalPositionBoolean;
            _reverseX = reverseX;
            _reverseY = reverseY;
            bones.sort(SORT_ON_BONE_ORG_POS);
        }
        
        /**
         * 左上を基準として表示位置でSlotをソートして返す
         * ※動作未検証
         */
        public static function sortSlotsByGlobalPosition(slots:Vector.<Slot>,reverseX:Boolean=false,reverseY:Boolean=false,useGlobalPositionBoolean=true):void
        {
            _useGlobalPositionBoolean = useGlobalPositionBoolean;
            _reverseX = reverseX;
            _reverseY = reverseY;
            slots.sort(SORT_ON_SLOT_ORG_POS);
        }
        
        /**
         * ボーン名でBoneをソートして返す
         */
        public static function sortBonesByAlphaOrder(bones:Vector.<Bone>,reverse=false):void
        {
            if(reverse)
            {
                bones.sort(Array.DESCENDING);
            }
            else
            {
                bones.sort(0);
            }
        }
        
        /**
         * スロット名でSlotをソートして返す
         */
        public static function sortSlotsByAlphaOrder(slots:Vector.<Slot>,reverse:Boolean=false):void
        {
            if(reverse)
            {
                slots.sort(Array.DESCENDING);
            }
            else
            {
                slots.sort(0);
            }
        }
        
    }
}