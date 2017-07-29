module Mouse
    exposing
        ( Event
        , Keys
        , Coordinates
        , Movement
        , Buttons
        , onDown
        , onMove
        , onUp
        , onWithOptions
        )

{-| Handling detailed mouse events.

@docs Event, Keys, Coordinates, Movement, Buttons

@docs onDown, onMove, onUp, onWithOptions

-}

import Html exposing (Attribute)
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Bitwise


-- MODEL #############################################################


{-| Type that get returned by a mouse event.
-}
type alias Event =
    { key : Keys
    , clientPos : Coordinates
    , offsetPos : Coordinates
    , movement : Movement
    , buttons : Buttons
    }


{-| The buttons pressed during mouse event.
-}
type alias Buttons =
    { left : Bool, right : Bool, wheel : Bool }


{-| The keys that might have been pressed during mouse event.
-}
type alias Keys =
    { alt : Bool, ctrl : Bool, shift : Bool }


{-| Coordinates of a mouse event.
-}
type alias Coordinates =
    ( Float, Float )


{-| Motion of a mouse movement.
-}
type alias Movement =
    ( Float, Float )



-- EVENTS ############################################################


{-| Listen to `mousedown` events.
-}
onDown : (Event -> msg) -> Attribute msg
onDown tag =
    Decode.map tag eventDecoder
        |> Events.onWithOptions "mousedown" stopOptions


{-| Listen to `mousemove` events.
-}
onMove : (Event -> msg) -> Attribute msg
onMove tag =
    Decode.map tag eventDecoder
        |> Events.onWithOptions "mousemove" stopOptions


{-| Listen to `mouseup` events.
-}
onUp : (Event -> msg) -> Attribute msg
onUp tag =
    Decode.map tag eventDecoder
        |> Events.onWithOptions "mouseup" stopOptions


{-| Choose the mouse event to listen to, and specify the event options.
-}
onWithOptions : String -> Events.Options -> (Event -> msg) -> Attribute msg
onWithOptions event options tag =
    Decode.map tag eventDecoder
        |> Events.onWithOptions event options


stopOptions : Events.Options
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }



-- DECODERS ##########################################################


eventDecoder : Decoder Event
eventDecoder =
    Decode.map5 Event
        (keyDecoder)
        (clientPosDecoder)
        (offsetPosDecoder)
        (movementDecoder)
        (buttonsDecoder)


keyDecoder : Decoder Keys
keyDecoder =
    Decode.map3 Keys
        (Decode.field "altKey" Decode.bool)
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "shiftKey" Decode.bool)


clientPosDecoder : Decoder Coordinates
clientPosDecoder =
    Decode.map2 (,)
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


offsetPosDecoder : Decoder Coordinates
offsetPosDecoder =
    Decode.map2 (,)
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


movementDecoder : Decoder Movement
movementDecoder =
    Decode.map2 (,)
        (Decode.field "movementX" Decode.float)
        (Decode.field "movementY" Decode.float)


buttonsDecoder : Decoder Buttons
buttonsDecoder =
    Decode.map3 Buttons
        (Decode.field "buttons" (decodeButton 1))
        (Decode.field "buttons" (decodeButton 2))
        (Decode.field "buttons" (decodeButton 4))


decodeButton : Int -> Decoder Bool
decodeButton id =
    Decode.int
        |> Decode.map (\int -> Bitwise.and int id /= 0)
