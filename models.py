from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime
from sqlalchemy.sql import quoted_name

db = SQLAlchemy()

class Branch(db.Model):
    __tablename__ = 'Branch'
    branch_id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    location = db.Column(db.String(100), nullable=False)
    phone_number = db.Column(db.String(20))

class Role(db.Model):
    __tablename__ = 'ROLE'
    role_id = db.Column(db.Integer, primary_key=True)
    role_name = db.Column(db.String(50), unique=True, nullable=False)
    permissions_description = db.Column(db.Text)

class RewardTier(db.Model):
    __tablename__ = 'REWARD_TIER'
    tier_id = db.Column(db.Integer, primary_key=True)
    tier_name = db.Column(db.String(50), unique=True, nullable=False)
    min_points_required = db.Column(db.Integer, nullable=False)
    discount_per_point = db.Column(db.Numeric(5, 2), nullable=False)

class IngredientCatalog(db.Model):
    __tablename__ = 'INGREDIENT_CATALOG'
    ingredient_id = db.Column(db.Integer, primary_key=True)
    ingredient_name = db.Column(db.String(100), unique=True, nullable=False)
    measurement_unit = db.Column(db.String(20), nullable=False)
    global_min_threshold = db.Column(db.Numeric(10, 2), nullable=False)
    substitution_category = db.Column(db.String(50))
    add_on_price = db.Column(db.Numeric(10, 2), nullable=False, default=0.00)

class Supplier(db.Model):
    __tablename__ = 'SUPPLIER'
    supplier_id = db.Column(db.Integer, primary_key=True)
    supplier_name = db.Column(db.String(100), nullable=False)
    contact_name = db.Column(db.String(100))
    phone = db.Column(db.String(20), unique=True)

class Campaign(db.Model):
    __tablename__ = 'CAMPAIGN'
    campaign_id = db.Column(db.Integer, primary_key=True)
    campaign_name = db.Column(db.String(100), nullable=False)
    point_multiplier = db.Column(db.Numeric(3, 2), nullable=False)
    end_date = db.Column(db.Date)

class MenuItem(db.Model):
    __tablename__ = 'MENU_ITEM'
    menu_item_id = db.Column(db.Integer, primary_key=True)
    item_name = db.Column(db.String(100), unique=True, nullable=False)
    base_price = db.Column(db.Numeric(10, 2), nullable=False)
    rating = db.Column(db.Integer, default=0)

class Staff(db.Model, UserMixin):
    __tablename__ = 'STAFF'
    staff_id = db.Column(db.Integer, primary_key=True)
    branch_id = db.Column(db.Integer, db.ForeignKey('Branch.branch_id'), nullable=False)
    role_id = db.Column(db.Integer, db.ForeignKey('ROLE.role_id'))
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(50), nullable=False)
    
    branch = db.relationship('Branch', backref='staff')
    role = db.relationship('Role', backref='staff')

    # Flask-Login requires get_id
    def get_id(self):
        return str(self.staff_id)

class Customer(db.Model):
    __tablename__ = 'CUSTOMER'
    customer_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    tier_id = db.Column(db.Integer, db.ForeignKey('REWARD_TIER.tier_id'), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    phone = db.Column(db.String(20), unique=True, nullable=False)
    total_points = db.Column(db.Integer, default=0)
    
    reward_tier = db.relationship('RewardTier', backref='customers')

class DiningTable(db.Model):
    __tablename__ = 'DINING_TABLE'
    table_id = db.Column(db.Integer, primary_key=True)
    branch_id = db.Column(db.Integer, db.ForeignKey('Branch.branch_id'), nullable=False)
    table_number = db.Column(db.Integer, nullable=False)
    seating_capacity = db.Column(db.Integer, nullable=False)
    table_state = db.Column(db.String(20), nullable=False)
    
    branch = db.relationship('Branch', backref='tables')

class Furniture(db.Model):
    __tablename__ = 'FURNITURE'
    furniture_id = db.Column(db.Integer, primary_key=True)
    branch_id = db.Column(db.Integer, db.ForeignKey('Branch.branch_id'), nullable=False)
    type = db.Column(db.String(50), nullable=False)

class BranchInventory(db.Model):
    __tablename__ = 'BRANCH_INVENTORY'
    inventory_id = db.Column(db.Integer, primary_key=True)
    branch_id = db.Column(db.Integer, db.ForeignKey('Branch.branch_id'), unique=True, nullable=False)
    manager_notes = db.Column(db.Text)
    last_updated = db.Column(db.DateTime)
    
    branch = db.relationship('Branch', backref='inventory')

class InventoryItem(db.Model):
    __tablename__ = 'INVENTORY_ITEM'
    inventory_id = db.Column(db.Integer, db.ForeignKey('BRANCH_INVENTORY.inventory_id'), primary_key=True)
    ingredient_id = db.Column(db.Integer, db.ForeignKey('INGREDIENT_CATALOG.ingredient_id'), primary_key=True)
    supplier_id = db.Column(db.Integer, db.ForeignKey('SUPPLIER.supplier_id'), nullable=False)
    quantity_on_hand = db.Column(db.Numeric(10, 2), nullable=False)
    
    inventory = db.relationship('BranchInventory', backref='items')
    ingredient = db.relationship('IngredientCatalog')
    supplier = db.relationship('Supplier')

class Recipe(db.Model):
    __tablename__ = 'RECIPE'
    recipe_id = db.Column(db.Integer, primary_key=True)
    menu_item_id = db.Column(db.Integer, db.ForeignKey('MENU_ITEM.menu_item_id'), nullable=False)
    ingredient_id = db.Column(db.Integer, db.ForeignKey('INGREDIENT_CATALOG.ingredient_id'), nullable=False)
    default_quantity = db.Column(db.Numeric(10, 2), nullable=False)

class Reservation(db.Model):
    __tablename__ = 'RESERVATION'
    reservation_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    customer_id = db.Column(db.Integer, db.ForeignKey('CUSTOMER.customer_id'), nullable=False)
    table_id = db.Column(db.Integer, db.ForeignKey('DINING_TABLE.table_id'), nullable=False)
    reservation_date = db.Column(db.Date, nullable=False)
    reservation_time = db.Column(db.Time, nullable=False)
    party_size = db.Column(db.Integer, nullable=False)
    
    customer = db.relationship('Customer', backref='reservations')
    table = db.relationship('DiningTable', backref='reservations')

class Order(db.Model):
    __tablename__ = quoted_name('ORDER', True)  # ORDER is a reserved MySQL keyword — must be quoted
    __table_args__ = {'extend_existing': True}
    order_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    table_id = db.Column(db.Integer, db.ForeignKey('DINING_TABLE.table_id'), nullable=False)
    staff_id = db.Column(db.Integer, db.ForeignKey('STAFF.staff_id'), nullable=False)
    branch_id = db.Column(db.Integer, db.ForeignKey('Branch.branch_id'), nullable=False)
    campaign_id = db.Column(db.Integer, db.ForeignKey('CAMPAIGN.campaign_id'))
    order_timestamp = db.Column(db.DateTime, nullable=False, default=db.func.current_timestamp())
    order_state = db.Column(db.String(20), nullable=False)
    order_type = db.Column(db.String(20), nullable=False, default='Dine-In')
    subtotal = db.Column(db.Numeric(10, 2), nullable=False, default=0.00)
    
    table = db.relationship('DiningTable')
    staff = db.relationship('Staff')
    branch = db.relationship('Branch')
    campaign = db.relationship('Campaign')

class OrderItem(db.Model):
    __tablename__ = 'ORDER_ITEM'
    order_item_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    order_id = db.Column(db.Integer, nullable=False)  # FK to ORDER.order_id — no SQLAlchemy ForeignKey due to reserved word
    menu_item_id = db.Column(db.Integer, db.ForeignKey('MENU_ITEM.menu_item_id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    unit_price = db.Column(db.Numeric(10, 2), nullable=False)
    
    order = db.relationship('Order', backref='items', primaryjoin='OrderItem.order_id == Order.order_id', foreign_keys='[OrderItem.order_id]')
    menu_item = db.relationship('MenuItem')

class MenuIngredientSubstitution(db.Model):
    __tablename__ = 'MENU_INGREDIENT_SUBSTITUTION'
    substitution_id            = db.Column(db.Integer, primary_key=True, autoincrement=True)
    menu_item_id               = db.Column(db.Integer, db.ForeignKey('MENU_ITEM.menu_item_id'), nullable=False)
    original_ingredient_id     = db.Column(db.Integer, db.ForeignKey('INGREDIENT_CATALOG.ingredient_id'), nullable=False)
    replacement_ingredient_id  = db.Column(db.Integer, db.ForeignKey('INGREDIENT_CATALOG.ingredient_id'), nullable=False)
    extra_cost                 = db.Column(db.Numeric(10, 2), nullable=False, default=0.00)

    menu_item            = db.relationship('MenuItem')
    original_ingredient  = db.relationship('IngredientCatalog', foreign_keys=[original_ingredient_id])
    replacement_ingredient = db.relationship('IngredientCatalog', foreign_keys=[replacement_ingredient_id])

class OrderItemModification(db.Model):
    __tablename__ = 'ORDER_ITEM_MODIFICATION'
    modification_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    order_item_id = db.Column(db.Integer, db.ForeignKey('ORDER_ITEM.order_item_id'), nullable=False)
    removed_ingredient_id = db.Column(db.Integer, db.ForeignKey('INGREDIENT_CATALOG.ingredient_id'))
    added_ingredient_id = db.Column(db.Integer, db.ForeignKey('INGREDIENT_CATALOG.ingredient_id'))
    mod_quantity = db.Column(db.Integer, default=1)
    extra_cost = db.Column(db.Numeric(10, 2), nullable=False, default=0.00)
    
    order_item = db.relationship('OrderItem', backref='modifications')
    removed_ingredient = db.relationship('IngredientCatalog', foreign_keys=[removed_ingredient_id])
    added_ingredient = db.relationship('IngredientCatalog', foreign_keys=[added_ingredient_id])

class Payment(db.Model):
    __tablename__ = 'PAYMENT'
    payment_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    order_id = db.Column(db.Integer, db.ForeignKey('ORDER.order_id'), unique=True, nullable=False)
    customer_id = db.Column(db.Integer, db.ForeignKey('CUSTOMER.customer_id'), nullable=False)
    payment_method = db.Column(db.String(20), nullable=False)
    subtotal_amount = db.Column(db.Numeric(10, 2), nullable=False)
    discount_applied = db.Column(db.Numeric(10, 2), default=0.00)
    final_amount = db.Column(db.Numeric(10, 2), nullable=False)
    payment_timestamp = db.Column(db.DateTime, nullable=False, default=db.func.current_timestamp())
    
    order = db.relationship('Order')
    customer = db.relationship('Customer')
