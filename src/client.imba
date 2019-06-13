const api = require('axios').create
const moment = require('moment')

tag ToolTip < svg:g
    attr transform

    prop x
    prop y

    def render
        let width = data.selected_leituras.toString:length * 7 + 9
        if (x < data.width / 2)
            transform = "translate({x},{y})"
        else
            transform = "translate({x - 30},{y})"
        <self transform=(transform)>
            <svg:rect height="30" width="{width}" style="fill: black">
            <svg:text fill="#ffffff" font-size="12" font-family="Nunito" x="5" y="20">
                data.selected_leituras * 100


tag Crosshair < svg:g
    def mouse_is_over_crosshair
        data.crosshair:x > 0 and data.crosshair:x < data.width - (data.chart_pos_x + 1) and 
        data.crosshair:y > 0 and data.crosshair:y < data.height - data.chart_pos_y

    def render
        <self>
            if mouse_is_over_crosshair
                <svg:g transform="translate({data.chart_pos_x},0)">
                    <svg:g opacity="1" transform="translate(0,{data.crosshair:y})">
                        <svg:line stroke="white" stroke-dasharray="5,5" x2="{data.width}">
                    <svg:g opacity="1" transform="translate({data.crosshair:x},0)">
                        <svg:line stroke="white" stroke-dasharray="5,5" y2="{data.width}">

tag Scale < svg:g
    def render
        <self>
            <svg:g transform="translate({data.width},0)">
                <svg:line stroke-width="0.5" stroke="white" y2="{data.height}">
            for i in Array.from Array(6).keys
                <svg:g transform="translate({i * data.width/6},0)">
                    <svg:line stroke-width="0.5" stroke="white" y2="{data.height}">

            <svg:g transform="translate(0,{data.width})">
                <svg:line stroke-width="0.5" stroke="white" x2="{data.width}">
            for i in Array.from Array(8).keys
                <svg:g transform="translate(0,{i * data.height/8})">
                    <svg:line stroke-width="0.5" stroke="white" x2="{data.width}">

tag Point < svg:circle
    attr r
    attr cx
    attr cy

    def render
        <self 
            style="fill: gray; stroke-opacity: 0.5; stroke: black;" 
            cx="{data:x || 0}" cy="{data:y || 0}" r="{data:r || 4}">

tag DataSerie < svg:g
    prop serie

    def line
        let path = serie.map do |p|
            "{p:x},{p:y}"

        'M' + path.join('L')

    def render
        <self>
            <svg:g transform="translate({data.chart_pos_x},0)">
                <svg:g style="fill: none;">
                    <svg:path style="stroke: orange; stroke-width: 2.5px;" d=line>
                for point, index in serie
                    <Point[point]>
                <ToolTip[data] x=serie[data.selected_point_index]:x y=serie[data.selected_point_index]:y>


tag LineChart

    prop indicador
    prop width         default: 0
    prop height        default: 250
    prop chart_pos_x   default: 0
    prop chart_pos_y   default: 50 
    prop bouding       default: 50
    prop points        default: null
    prop dates         default: [] 
    prop leituras      default: []
    prop max           default: 0
    prop min           default: 0
    prop pixel_unit_y  default: 0
    prop pixel_unit_x  default: 0
    prop crosshair     default: {x: 0,  y: 0}
    prop page_size     default: 50
    prop main_chart
    prop selected_leituras
    prop selected_point_index
    prop leitura_count default: 50

    def mount
        console.log data
        window:onresize = do
            width = dom:offsetWidth
            render
        width = dom:offsetWidth
        render

    def calc_points
        return unless data and data[0]
        leituras = data.slice.reverse.map do |l| 1/l * height
        let values = leituras
        max = 1.1 * Math.max *values
        min = 1.1 * Math.min *values
        pixel_unit_y = (height - chart_pos_y)/max
        pixel_unit_x = (width - chart_pos_x)/(values:length - 1)
        let values = values.map do |p| 
            pixel_unit_y * p - min
        
        points = values.map do |point, i|
            x: i*pixel_unit_x
            y: height - point - chart_pos_y

    def update_crosshair e
        let bound = main_chart.dom.getBoundingClientRect
        crosshair = 
            x: e.event:x - bound:x - chart_pos_x
            y: e.event:y - bound:y

    def update_points
        let point_index = parseInt((crosshair:x + (pixel_unit_x/2)) / pixel_unit_x)
        let temp_index = Math.round((point_index)*2)/2
        
        if temp_index >= 0 and temp_index < points:length
            selected_point_index = temp_index
            points[selected_point_index]:r = 10
            selected_leituras = leituras[selected_point_index]


    def render
        calc_points 
        update_points 
        <self .main_chart>
            main_chart = <svg:svg :mousemove.prevent.update_crosshair width="{width or 0}" height="{height or 0}">
                if points
                    <Crosshair[self]>
                    <Scale[self]>
                    <DataSerie[self] serie=(points)>


tag App

    prop leituras default: []
    prop valores default: []
    prop last_request

    def mount
        schedule interval: 100
        last_request = moment()

    def unmount
        unschedule
        
    def tick
        if moment().diff(last_request) >= 100
            last_request = moment()
            leituras = (await api({ 
                url: "http://localhost:3001/leituras", 
                method: 'get'
            })):data
            valores = leituras.map do |l| 1/l * 250
        render

    def render
        <self>
            <div .app>
                <header .content__title>
                    <h1>
                        "Trabalho Final"
                    <div .row>    
                        <div .col>    
                            <header .content__title>
                                <small>
                                    "Cassiano Franco"
                                <small>
                                    "Cassiano Zucco"
                                <small>
                                    "Élvis Martello"
                                <small>
                                    "Lucas Rodrigues"
                                <small>
                                    "Eduardo Ferrarezi"
                        <div .col>    
                            <header .content__title>
                                <small>
                                    "Rodrigo Matheus Rotava"
                                <small>
                                    "Giovani Padoin"
                                <small>
                                    "Willian Agostini"
                                <small>
                                    "Matheus Grigol Ortolan"

                <header .content__title>
                    <div .card>
                        <div .card-header>
                            <header .content__title>
                                <h1>
                                    "Luminosidade"
                                <small>
                                    "Média: {(valores.reduce((do |a,b| a + b), 0) / leituras:length) * 100}"
                                <small>
                                    "Mínima: {(Math.min *valores) * 100}"
                                <small>
                                    "Máxima: {(Math.max *valores) * 100}"
                        <LineChart[leituras]>


Imba.mount <App>