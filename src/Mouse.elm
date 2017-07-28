module Mouse
    exposing
        ( Event
        , Keys
        , Coordinates
        , Movement
        , Button (..)
        , onDown
        , onMove
        , onUp
        , onWithOptions
        )

{-| Handling detailed mouse events.

@docs Event, Keys, Coordinates, Movement

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
    , buttons : List Button
    }

type Button
    = Left
    | Right
    | Wheel
    | BrowserForward
    | BrowserBack


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



buttonsDecoder : Decoder (List Button)
buttonsDecoder =
    let
        buttonNumber : Button -> Int
        buttonNumber button =
            case button of
                Left ->1
                Right -> 2
                Wheel -> 4
                BrowserForward -> 8
                BrowserBack -> 16

        buttonIsPressed pressedInt button =
            0 /= Bitwise.and pressedInt (buttonNumber button)

        decodeFunction pressedInt =
            List.filter (buttonIsPressed pressedInt) <| [Left, Right, Wheel, BrowserForward, BrowserBack]
    in
        Decode.map decodeFunction <| Decode.field "buttons" Decode.int
