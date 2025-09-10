import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';
import 'package:mobile/service_locator.dart';
// Comentamos temporalmente las importaciones de ubicación
// import 'package:geolocator/geolocator.dart' hide Position;
// import 'package:location/location.dart';

class ClinicsMapScreen extends StatefulWidget {
  const ClinicsMapScreen({super.key});

  @override
  State<ClinicsMapScreen> createState() => _ClinicsMapScreenState();
}

class _ClinicsMapScreenState extends State<ClinicsMapScreen> {
  final campusService = serviceLocator<ForQueryingCampus>();
  final TextEditingController _searchController = TextEditingController();
  List<Campus> _campusList = [];
  bool _isSearching = false;
  bool _showResults = false;

  MapboxMap? mapboxMap;
  CameraOptions cameraOptions = CameraOptions(
    center: Point(coordinates: Position(-33.444541, -70.652830)),
    zoom: 12.0,
  );
  final String mapStyle =
      'mapbox://styles/alessandrorlm/cmfbxp33m000d01s4az8dbz68';

  @override
  void initState() {
    super.initState();
    // Desactivada la solicitud de permisos de ubicación temporalmente
    // _requestLocationPermission();
    _loadCampusData();
  }

  Future<void> _loadCampusData() async {
    final campusList = await campusService.getCampus(null);
    setState(() {
      _campusList = campusList;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método comentado temporalmente
  /*
  Future<void> _requestLocationPermission() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _crearMapa(),
          SafeArea(
            child: Column(
              children: [
                // Barra de búsqueda y botón de volver
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Botón de volver
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // Campo de búsqueda
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar campo clínico',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _isSearching
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _isSearching = false;
                                          _showResults = false;
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            onChanged: (value) async {
                              setState(() {
                                _isSearching = value.isNotEmpty;
                                _showResults = value.isNotEmpty;
                              });
                              if (value == '') {
                                _campusList = await campusService.getCampus(
                                  null,
                                );
                              }
                              _campusList = await campusService.getCampus(
                                value,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de resultados de búsqueda
                if (_showResults)
                  Container(
                    margin: const EdgeInsets.fromLTRB(64.0, 0, 8.0, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: _campusList.isEmpty
                        ? const ListTile(
                            title: Text('No se encontraron resultados'),
                            leading: Icon(Icons.info_outline),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _campusList.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final campus = _campusList[index];
                              return ListTile(
                                title: Text(campus.name),
                                subtitle: Text(
                                  '${campus.commune}, ${campus.city}',
                                ),
                                leading: const Icon(
                                  Icons.local_hospital,
                                  color: AppThemes.primary_600,
                                ),
                                onTap: () {
                                  setState(() {
                                    _showResults = false;
                                    _searchController.text = campus.name;
                                  });

                                  // Centrar el mapa en la ubicación del campus
                                  if (mapboxMap != null) {
                                    mapboxMap!.flyTo(
                                      CameraOptions(
                                        center: Point(
                                          coordinates: Position(
                                            campus.longitude,
                                            campus.latitude,
                                          ),
                                        ),
                                        zoom: 15.0,
                                      ),
                                      MapAnimationOptions(duration: 1000),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                const Spacer(),
                // Botones de zoom y ubicación actual
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botones de zoom
                        Container(
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: AppThemes.primary_600,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppThemes.primary_600,
                                ),
                                onPressed: _zoomPlus,
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: AppThemes.primary_600,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: AppThemes.primary_600,
                                ),
                                onPressed: _zoomMinus,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Botón de ubicación actual
                        Container(
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: AppThemes.primary_600,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.my_location,
                              color: AppThemes.primary_600,
                            ),
                            onPressed: _goToCurrentLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _zoomPlus() async {
    if (mapboxMap != null) {
      final currentZoom = await mapboxMap!.getCameraState().then(
        (value) => value.zoom,
      );
      mapboxMap!.setCamera(CameraOptions(zoom: currentZoom + 1));
    }
  }

  void _zoomMinus() async {
    if (mapboxMap != null) {
      final currentZoom = await mapboxMap!.getCameraState().then(
        (value) => value.zoom,
      );

      mapboxMap!.setCamera(CameraOptions(zoom: currentZoom - 1));
    }
  }

  void _goToCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de ubicación desactivada temporalmente'),
      ),
    );

    // La funcionalidad real está comentada temporalmente
    /*
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mapboxMap != null) {
        mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la ubicación actual')),
      );
    }
    */
  }

  Widget _crearMapa() {
    return MapWidget(
      styleUri: mapStyle,
      cameraOptions: cameraOptions,
      onMapCreated: _onMapCreated,
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
  }
}
