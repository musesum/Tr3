# Tr3

Tr3 (pronounced "Tree") is a functional data flow graph with the following features

- Nodes with: edges, values, and closures
- Edges connecting: namespace tree, inputs, and outputs
- Script describing graph in idiomatic Swift

### Nodes

Each node at least one parent node and zero or more child nodes:  
```c
a  { b c } // a has two children b & c while b & c have one parent a
```
Declaring a path will auto create a tree of names
```swift
a.b.c // produces the structure a { b { c } }
```
A tree can be decorated with another tree
```swift
a {b c}:{d e} // produces a { b { d e } c { d e } }
```
A tree can subclass another tree
```swift
a {b c}:{d e} // produces a { b { d e } c { d e } }
z:a // produces z { b { d e } c { d e } }
```
### Edges

Nodes connect to each other via edges
```swift
b -> c // b flows to c, akin to a function call
d <- e // d flows from e, akin to a callback
f <-> g // f & g flow between each other, akin to sync
```
Nodes activate other nodes when its value changes or when it is activated by other nodes

Nodes can have activation loops:
```swift
a -> b // if a activates, it will active b
b -> c // which, in turn, actives c
c -> a // but, c stops here
```
A Tr3 event collects a set of nodes it has visited.
When it find a node it already has visited, it stops.
So, in the a,b,c example, the activation could start anywhere:
```swift
a -> b -> c
b -> c -> a
c -> a -> b
```
This is a simple way to synchronize a model. Akin to how a co-pilot's wheel synchronizes in a cockpit.

### Values

Each node may have scalar, tuple, or string
```swift
a: 1              // an initial value of 1
b: (0...1)      // a ranged value between 0 and 1
c: (0...127=1)  // a ranged vale between 0 and 127, initialized to 1
d: ( 0 0 0)     // three unnamed float values
e: (x y z):(0...1=0)  // three named float values with range 0...1=0
f: "yo"         // a string value "yo"
```
Tr3 automatically remaps scalar ranges, given the nodes b & c
```swift 
b: (0...1)      // range 0 to 1
c: (0...127=1)  // range 0 to 127, with initial value of 1
b <-> c         // synchronize b and c and auto-remap values
```
When the value of b is changed to 0.5, it activates C and remaps its value to 63.
A common case are sensors, which have a fixed range of values.
For example: a 3G (gravity) accelerometer  may have a range been -3.0...3.0,
```swift 
accelerometer: (x y z):(-3.0...3.0) -> model
model: (x y z):(-1...1) // rescale
```
Nodes may pass through values
```swift
a:(0...1) -> b  // may pass along value to b
b -> c          // has no value; forwards a to c
c:(0...10)      // gets a's value via b, remaps ranges
```
Edges may contain values
```swift
d -> e:(0...1):1 // an activated d sends an ranged 1 to e
```
#### Overrides, and wildcards

override nodes with values
```swift
a {b c}:{d e} // produces  a { b { d e } c { d e }
a.b.d:1 // results in  a { b { d:1 e } c { d e }
```
Wildcard connections, with new ˚ (option-k) wildcard
```swift
p <- a.*.d  // produces p <- (a.b.d a.c.d)
q <- a˚d      // produces q <- (a.b.d a.c.d)
r <- a˚.      // produces r <- (a.b.d a.b.e a.c.d a.c.e)
s <- a˚˚      // produces s <- (a a.b a.b.d a.b.e a.c a.c.d a.c.e)
```
In above, the ˚ operators is akin to an xpath's // search node no mater where they are

Variations include ˚. to find leaf nodes, ˚˚ include all greedy all nodes
```swift
˚˚<-..  // flow from each node to its parent, bottom up
˚˚->.*  // flow from each node to its children, top down
˚˚<->.. // flow in both directions,  middle out?
```
Because the visitor pattern breaks loops, the ˚˚<->..  maps well to devices that combine sensors and actuators, such as a flying fader on a mix board, a co-pilot's steering wheel, or the joints on an android robot.

### Ternaries

conditionals may switch the flow of data
```swift
a -> (b ? c : d)  // a flows to either c or d, when b activates
e <- (f ? g : h)  // f directs flow from either g or h, when f acts
i <-> (j ? k : l) // i synchronizes with either k or l, when j acts
m <-> (n ? n1 | p ? p1 | q ? q1) //  radio button style
```
conditionals may also compare its state
```swift
a -> (b > 0 ? c : d) // a flows to either c or d, when b acts (default behavior)
e <- (f == 1 ? g : h) // g or h flows to e, based on last f activation
i <-> (j1 < j2 ? k : l) // i syncs with either k or l, based on last j1 or j2 acts
m <-> (n > p ? n1 | p > q ? p1 | q > 0 ? q1) // radio button style
```
when a comparison changes is state, it reevaluates its chain of conditions

- when b activates, it reevaluates b > 0
- when f activates, it reevaluates f == 1
- when either j1 or j2 activates, it reevals j1 < j2
- when n, p, or q acts, it reevals n>p, p>q, and q>0

Ternaries act like railroad switches the condition merely switches the gate, where each event passing through that gate does not need re-invoke the condition

- when b acts, it connects c and disconnects d
- when n, p, or q acts, it is switching between n1, p1, q1

ternaries may aggregate or broadcast
```swift
a:{b c}:{d e}:{f g} // produces a{b {d {f g} e {f g}} c {d {f g} e {f g}}
p -> (a.b ? b˚. | a.c ? c˚.) // broadcast p to all leaf nodes of either b or c
q <- (a.b ? b˚. | a.c ? c˚.) // aggregate to q from all leaves of either b or c
```

### Closures

A .swift source may attach a closure to a Tr3 node
```swift
brushSize˚  = brush.findPath("sky.draw.brush.size");
brushSize˚?.addClosure  { tr3,_ in
self.brushRadius = tr3.CGFloatVal() ?? 1 }
```
In the above example, brushSize˚ attaches a closure to sky.draw.brush.size, which then updates its internal value brushRadius.

(BTW, the ˚ in brushSize˚ is merely a naming convention; you can call it anything)

### Embedded  Script
```swift
shader {{
// Metal or Vulcan code goes here
}}
```
The previous version of Tr3 supported embed OpenGL Shaders. Which could be compiled at runtime.

The new version of Tr3 will support embedded Metal Shaders. Untested with toy app: "Muse Sky.

## Use cases

#### Platform for visual music synthesis and real-time media performance

Toy Visual Synth for iPad and iPhone called "Muse Sky"
- See script in Tests/Tr3Tests/testSky()
- pretty version of output in  Tests/Tr3Tests/SkyOutput.h
- code folding and syntax highlighting works in Xcode
- coming soon to Apple App store late 2019/2020
- Demo [here](https://www.youtube.com/watch?v=peZFo8JnhuU)

encourage users to tweak Tr3 scripts without recompiling
- pass along Tr3 scripts, somewhat akin to Midi files for music synthesis
- connect musical instruments to visual synth via OSC, Midi, or proprietary APIs

inspired by
- analog music synthesizers, like Moog Modular, Arp 260, with patchcords
- dataflow languages : Max, QuartzComposer, TensorFlow

#### Avatars and Robots

Check out Robot.h, which shows the output of an android robot skeleton defined in 3 lines of code:
```swift
robot {left right}:{shoulder.elbow.wrist {thumb index middle ring pinky}:{meta prox dist} hip.knee.ankle.toes}
˚˚ <-> .. // connect every node to its parent
˚˚:{pos:(x y z):(0...1) angle:(roll pitch yaw):(%360) mm:(0...3000)})
```
Apply machine learning to representation of graph
- Record total state of `graph <- robot˚˚`
- Playback total state of `graph -> robot˚˚`
- Inspired by a Kinect/OpenNI experiment, shown [here](https://www.youtube.com/watch?v=aFO6j6tvdk8)

#### SpaceCraft NASA Virtual IronBird

NASA conference on representing spacecraft in an functional ontology
- Simulate spacecraft by mapping all architecture, sensor, actuators
- Contingency planning by apply GANs (Generative Adversarial Networks)

#### Project Management

- Map work breakdown structure to hierarchy.
- Map activities to nodes with values as cost, duration, and constraints

#### Smart Cities

- Model sensors and traffic signals into an ontology.
- Apply Machine learning to find threats and optimize energy and flow of people
- Contingency planning by apply GANs

#### Companion packages

Par -  parser for DSLs and flexible NLP in Swift

- tree + graph base parser
- contains a definition of the Tr3 Syntax
- vertically integrated with Tr3
- Source [here](https://github.com/musesum/Par)

Tr3D3 (pending)

- simple visualization of the Tr3 graph, using D3JS
- continuation of prototype of previous version of Tr3
- Proof of concept [here]( https://www.youtube.com/watch?v=a703TTbxghc)
(from previous version of Tr3, using Prefuse Toolkit)

Tr3Dock (pending)

- Tr3 based UI
- Demo [here](https://www.youtube.com/watch?v=peZFo8JnhuU)

#### Implications

User readable code

Tr3 runtime was ported from C++ to Swift. There are several incentives:
- Attaching Swift closures to C++ was complicated
- `TensorFlow for Swift` project implies a single code base
- Future support for `TensorFlow/MLIR`

Works well within XCode IDE
- special attention to syntax highlighting and code folding in XCode
- Tr3 script follows Swift idiom

Cross between Swift and Json
- no parsing conveniences like ; and , that obfuscate Human readability
- intermediate step

#### Amorphous computation:

While the visitor pattern naturally maps to multithreading on a traditional CPU, it also maps to neuromorphic computing, where each node is its own processor, comparing its ID with the visitors ID and refusing to activate if already visited. Somewhat akin to the McCoullough-Pitts neural model, which modelled a refractory period.

A future version of Tr3 will refractory periods at the node level.

# Future

#### parsing
- Better error trapping for parsing errors
- Merge with Par, where modified BNF becomes a value type
- Command line interpreter to create and manipulate graphs

#### Values

- Tr3ValBool — add boolean value support
- Tr3ValRegx — regular expression strings
- Tr3ValPar — integrate Par  NLP/DSL parser

#### Edges

- Refractory periods for edges (ADSR style)
- change parent [child] contains to edges
- runtime edge creation, akin to neuroplasticity

compute shaders -> compiler

- embed Metal shaders (for Muse Sky app)
- integrate TensorFlow via CoreML
- integrate TensorFlow/MLIR?
- support AutoGraph?

visual editor - extend Tr3D3 to allow
- live editing of scripted nodes, edges, values
- query subgraphs via search bar or selecting 2 or more nodes

IBM HIPO style node inspector showing
- hierarchy of inputs
- hierarchy of outputs

compiler
- ostensibly integrate with TensorFlow/MLIR a
- support an AutoGraph-like conversion of procedural code to a flow graph
- support new scalars for ML

Secure computing with Petri Nets
- The visitor pattern collects previously visisted nodes,
- whereby the node to stops if it had already been visited once.

Secure synchronization by extending the visitor set
- whereby the node only executes only when a required set matches.

#### Research

Create an artificial Temporal Huffman machine

- Given that a Visitor pattern already collects previously visited nodes
- Apply attack waveforms (ADSR) to attenuate vivacity of each visited Node
- Aggregate vivacities to active higher probabilities sooner
- Apply refractory periods to block lower probabilities

Model biological Neocortex

- Support runtime generation of connections to emulate neuroplasticity
- Apply MLIR to support upto 30K edges to simulate Axon connections

Apply to realtime handwriting recognition
