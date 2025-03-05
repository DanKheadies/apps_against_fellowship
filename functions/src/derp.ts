// // let reorder = (map, keys) =>
// //     new Map(keys.map(k => [k, map.get(k)]))

// // let rotate = (ary, n) =>
// //   ary.slice(n).concat(ary.slice(0, n))

// // const myMap = new Map();
// // myMap.set('a', 1);
// // myMap.set('b', 2);
// // myMap.set('c', 3);
// // myMap.set('d', 4);

// // keys = [...myMap.keys()]
// // newMap = reorder(myMap, rotate(keys, keys.indexOf('c')))
// // console.log([...newMap.entries()])

// const rawIndexes = [
//   "e848c470f36bdf2a879aaa06713d94e4ee37a9fa9bfc658f69ccf49dcb2d5e5f",
//   "a6158d61e6d3025b1942ca86d1060a95361d51f3836a555335cf25ff9875d860",
// ];

// const submittedResponses = [
//   {
//     cid: "a6158d61e6d3025b1942ca86d1060a95361d51f3836a555335cf25ff9875d860",
//     text: "The corporations.",
//     set: "CAH Second Expansion",
//     source: "CAH Expansions",
//   },
//   {
//     cid: "e848c470f36bdf2a879aaa06713d94e4ee37a9fa9bfc658f69ccf49dcb2d5e5f",
//     text: "Me.",
//     set: "CAH Second Expansion",
//     source: "CAH Expansions",
//   },
// ];

// function orderMyMap(myMap: Map<any, any>, key: string) {
//   const array = Array.from(myMap);
//   const newArray = [
//     ...array.splice(
//       array.findIndex((arr) => arr[0] === key),
//       array.length
//     ),
//     ...array,
//   ];

//   const newMap = new Map();

//   newArray.map((values) => {
//     newMap.set(values[0], values[1]);
//   });
//   return newMap;
// }

// // orderMyMap();

// // function reorderMaps<T extends { id: any }>(maps: T[], ids: any[]): T[] {
// //   const mapIndex: { [key: string]: number } = {};
// //   maps.forEach((map, index) => {
// //     mapIndex[map.id] = index;
// //   });

// //   const reorderedMaps = ids
// //     .map((id) => maps[mapIndex[id]])
// //     .filter((map) => map !== undefined);
// //   return reorderedMaps;
// // }

// // // Example Usage:
// // const list = [
// //   { id: 3, name: "Charlie" },
// //   { id: 1, name: "Alice" },
// //   { id: 2, name: "Bob" },
// // ];

// // const order = [1, 2, 3];

// function reorderMaps<T extends { cid: any }>(maps: T[], ids: any[]): T[] {
//   const mapIndex: { [key: string]: number } = {};
//   maps.forEach((map, index) => {
//     mapIndex[map.cid] = index;
//   });

//   const reorderedMaps = ids
//     .map((id) => maps[mapIndex[id]])
//     .filter((map) => map !== undefined);
//   return reorderedMaps;
// }

// // const reorderedList = reorderMaps(list, order);
// const reorderedList = reorderMaps(submittedResponses, rawIndexes);
// console.log(reorderedList);
// // Expected output:
// // [
// //     { id: 1, name: 'Alice' },
// //     { id: 2, name: 'Bob' },
// //     { id: 3, name: 'Charlie' }
// // ]
