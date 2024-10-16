class Encoder a where
    encode :: Program a -> String

data SchemONEncoder = SchemONEncoder
instance Encoder SchemONEncoder where
    encode EOF = ""
    encode (Message pair EOF) = encodePair pair
    encode (Message pair enc) = encodePair pair ++ "\n" ++ encode enc

data Program a = Message (SPair a) (Program a) | EOF deriving (Show)

data SType a = TStr | TInt | TFloat | TBool | TChar | TList (SType a) | TObj (ObjRValue a) | TCustom String deriving (Show)
data SPair a = SPair String (SType a) deriving (Show)

type ObjRValue a = [SPair a]

encodePair :: SPair a -> String
encodePair (SPair name t) = name ++ ": " ++ encodeType t

encodePairs :: [SPair a] -> String
encodePairs [] = ""
encodePairs [x] = encodePair x
encodePairs (x:xs) = encodePair x ++ ", " ++ encodePairs xs

encodeType :: SType a -> String
encodeType t = case t of
    TStr -> "str"
    TInt -> "int"
    TFloat -> "float"
    TBool -> "bool"
    TChar -> "char"
    TList a -> "[" ++ encodeType a ++ "]"
    TObj a -> "{" ++ encodePairs a ++ "}"
    TCustom s -> s


-- Test program

program :: Program a
packet :: SPair a
translate :: SPair a

program = Message packet $ Message translate EOF
packet = SPair "packet" (TObj [SPair "id" TInt])
translate = SPair "translate" (TObj [SPair "packet" (TCustom "packet"), SPair "dx" TFloat, SPair "dy" TFloat])

main = do
    putStrLn $ encode (program :: Program SchemONEncoder)