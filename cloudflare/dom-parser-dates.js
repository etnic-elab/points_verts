addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

const url = "https://www.am-sport.cfwb.be/adeps/pv_data.asp?type=dates";
const regex = new RegExp('[0-9]{2}-[0-9]{2}-[0-9]{4}', 'gm');

/**
 * Respond to the request
 * @param {Request} request
 */
async function handleRequest(request) {
  const fetchResult = await fetch(url);
  const text = await fetchResult.text();
  const arr = text.match(regex) || [""]
  const response = new Response(JSON.stringify(arr), {status: 200})
  response.headers.set("Content-Type", "application/json");
  return response;
}