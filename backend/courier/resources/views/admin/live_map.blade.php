@extends('layouts.app')

@section('content')
<div class="container pt-5">
    <h2 class="mb-4">Live Courier Map</h2>
    <div id="liveMap" style="height: 600px; border-radius: 8px; overflow: hidden;"></div>
</div>
@endsection

@push('styles')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css" />
@endpush

@push('scripts')
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet.markercluster@1.5.3/dist/leaflet.markercluster.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function () {
    const map = L.map('liveMap').setView([42.0087, 20.9716], 12);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    let markers = L.markerClusterGroup();
    map.addLayer(markers);

    function loadMarkers() {
        fetch('/api/online-users')
            .then(response => response.json())
            .then(users => {
                markers.clearLayers();

                users.forEach(user => {
                    if (user.role !== 'courier') return;
                    if (!user.current_latitude || !user.current_longitude) return;

                    const lat = parseFloat(user.current_latitude);
                    const lng = parseFloat(user.current_longitude);

                    const avatar = user.avatar
                        ? `<img src="${user.avatar}" width="50" style="border-radius:50%">`
                        : `<div style="width:50px;height:50px;border-radius:50%;background:#007bff;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:bold;">${user.name.charAt(0)}</div>`;

                    const updated = user.last_updated_at ? new Date(user.last_updated_at).toLocaleString() : '';

                    const popup = `
                        <div class="text-center">
                            ${avatar}
                            <p style="margin-top:5px;"><strong>${user.name}</strong><br>
                            Last seen: ${updated}</p>
                        </div>
                    `;

                    const marker = L.marker([lat, lng]).bindPopup(popup);
                    markers.addLayer(marker);
                });

                setTimeout(() => {
                    map.invalidateSize();
                }, 300);
            })
            .catch(error => console.error('Map fetch error:', error));
    }

    loadMarkers();
    setInterval(loadMarkers, 30000); // Refresh every 30s
});
</script>
@endpush
